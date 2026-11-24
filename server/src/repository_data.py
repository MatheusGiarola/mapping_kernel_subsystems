import pandas as pd

from math import log
import colorsys

def load_pandas_csv_at(path_to_csv,separator=','):
    try:
        data_df = pd.read_csv(path_to_csv,sep=separator)
    except:
        data_df = pd.read_csv(path_to_csv,sep='·')
    data_df.set_index("identifier",inplace=True)
    return data_df

class RepositoryData():

    def __init__(self):
        self.data_df = pd.DataFrame()

    def record_dir_entry(self,entry: dict, dir_path: str, checkpoint: bool = False):
        """
        Adds to the repository data information on a single directory.
        """
        identifier = dir_path
        full_entry = entry | {"identifier": identifier}
        entry_df = pd.DataFrame([full_entry])
        entry_df.set_index("identifier",inplace=True)
        self.data_df = pd.concat([self.data_df, entry_df])

        if checkpoint:
            self.save_to()

    def record_file_entries(self, entries: list[dict], parent_path: str, checkpoint: bool = False):
        """
        Adds to the repository data information on multiple files
        from a given directory.
        """
        for dict_index in range(len(entries)):
            this_dict = entries[dict_index]
            entries[dict_index] = this_dict | {"identifier": parent_path + "/" + this_dict["node_name"]} 
        entries_df = pd.DataFrame(entries)
        entries_df.set_index("identifier",inplace=True)
        self.data_df = pd.concat([self.data_df, entries_df])

        if checkpoint:
            self.save_to()
    
    def produce_treemap_data(self, metric="files") -> dict:
        """
        Generates a tuple of lists with the data necessary for the plotly treemap
        of the data.
        """

        def get_row_parent(row) -> str:
            identifier = row.name
            node_name = row["node_name"]
            if identifier == "Linux kernel": return ""
            try:
                _ = len(node_name)
            except:
                return ''
            
            suffix_len = len(node_name) + 1
            return identifier[:-suffix_len]

        self.data_df['parents'] = self.data_df.apply(get_row_parent, axis=1)
        
        def normalize_sizes(row) -> float:
            if metric == "LOC":
                return 0 if pd.isna(row["LOC"]) else float(row["LOC"])

            return 0 if pd.isna(row["n_files"]) else float(row["n_files"])
            
        
        def printable_sizes(row) -> str:
            nome = "/" if pd.isna(row["node_name"]) else str(row["node_name"])
            if nome == str(row["subsystem"]) and pd.notna(row.get("mailing_list")):
                return f"{nome}<br>Mailing list: {row['mailing_list']}"
            return nome

        palette = [
            "#2E91E5", "#E15F99", "#1CA71C", "#FB0D0D", "#DA16FF", "#222A2A",
            "#B68100", "#750D86", "#EB663B", "#511CFB", "#00A08B", "#FB00D1",
            "#FC0080", "#B2828D", "#6C7C32", "#778AAE", "#862A16", "#A777F1",
            "#620042", "#1616A7", "#DA60CA", "#6C4516", "#0D2A63", "#AF0038",
            "#FD3216", "#00FE35", "#6A76FC", "#FED4C4", "#FE00CE", "#0DF9FF",
            "#F6F926", "#FF9616", "#479B55", "#EEA6FB", "#DC587D", "#D626FF",
            "#6E899C", "#00B5F7", "#B68E00", "#C9FBE5", "#FF0092", "#22FFA7",
            "#E3EE9E", "#86CE00", "#BC7196", "#7E7DCD", "#FC6955", "#E48F72"
        ]
        subs_unique = self.data_df["subsystem"].dropna().unique()
        mapa_cores = {sub: palette[i % len(palette)] for i, sub in enumerate(subs_unique)}

        self.data_df['colors'] = self.data_df["subsystem"].map(mapa_cores).fillna("#E5E5E5")

        data_as_dict = {
            "ids": self.data_df.index.fillna('').to_list(),
            "labels": self.data_df["node_name"].fillna('/').to_list(),
            "parents": self.data_df["parents"].to_list(),
            "sizes": self.data_df.apply(normalize_sizes, axis=1).to_list(),
            "actual_sizes" : self.data_df.apply(printable_sizes, axis=1).to_list(),
            "colors": self.data_df["colors"].to_list()
            }

        return data_as_dict

    def set_save_path(self, save_to_path: str):
        """
        Sets the address to be used when saving this repository data.
        """

        self.save_to_path = save_to_path

    def load_from(self,path: str,separator=","):
        """
        Loads data from a .csv at a given path.
        """
        self.data_df = load_pandas_csv_at(path,separator)

    def save_to(self, output_path: str|None = None):
        """
        Saves data to a .csv at the given path.
        """

        if output_path is None:
            output_path = self.save_to_path

        self.data_df.to_csv(output_path)