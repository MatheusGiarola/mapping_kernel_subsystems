# Mapeamento e Visualização dos Subsistemas do Kernel Linux

## Sobre o projeto

O kernel Linux é dividido em mais de 80 subsistemas, cujos limites raramente 
coincidem com um único diretório do código-fonte e são bastante difusos, o que torna difícil 
compreender como o projeto está de fato organizado.

Este projeto tem como objetivo mapear os subsistemas do kernel Linux a partir 
do arquivo MAINTAINERS e construir uma prova de conceito de um treemap que 
visualize essa organização.

## Objetivos

- Extrair e fazer o parsing do arquivo MAINTAINERS
- Construir um mapeamento entre arquivos do kernel e seus respectivos subsistemas
- Identificar e documentar casos de sobreposição entre subsistemas
- Desenvolver uma prova de conceito de um treemap para visualizar essa organização

**Orientação:** Prof. Paulo Meirelles e doutorando Arthur Pilone

---

**Nota:** Esse repositório documenta o desenvolvimento do projeto realizado na
disciplina [MAC0214- Atividade Curricular em Cultura e Extensão](https://uspdigital.usp.br/jupiterweb/obterDisciplina?sgldis=MAC0214),
 do IME-USP.
