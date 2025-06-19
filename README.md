# 🏰 ** Tower Defense - Linguagens de Programação**

## 🛡️ Visão Geral do Projeto

`Defesa do Reino` é um jogo de *Tower Defense* desenvolvido em **Love2D** e programado em **Lua**. Nosso objetivo é criar uma experiência estratégica onde os jogadores devem defender uma estrutura central contra hordas implacáveis de inimigos, recrutando soldados e aprimorando suas defesas. Este projeto está sendo desenvolvido por uma equipe de 4 alunos do terceiro ano de computação, com um prazo de 1 mês.

-----

## 🚀 Como Executar o Jogo

Para rodar `Defesa do Reino`, você precisará ter o **Love2D** instalado em sua máquina.

1.  **Baixe o Love2D:**

      * Visite o site oficial do Love2D: [love2d.org](https://love2d.org/)
      * Siga as instruções de instalação para o seu sistema operacional.

2.  **Clone o Repositório:**

    ```bash
    git clone https://github.com/SeuUsuarioOuOrganização/NomeDoRepositorio.git
    cd NomeDoRepositorio
    ```

    *(Substitua `SeuUsuarioOuOrganização/NomeDoRepositorio` pelo caminho correto do seu repositório no GitHub.)*

3.  **Execute o Jogo:**

      * **Windows:** Arraste a pasta clonada (`NomeDoRepositorio`) para o executável `love.exe`.
      * **Linux/macOS:** Navegue até a pasta clonada no terminal e execute `love .`
        ```bash
        love .
        ```

-----

## ⚙️ Estrutura de Diretórios

A organização do código é crucial para um projeto em equipe e com prazo apertado. Adotamos uma estrutura modular para facilitar a navegação e a colaboração:

```
NomeDoRepositorio/
├── main.lua              # Ponto de entrada principal do jogo, gerencia o game loop e estados.
├── conf.lua              # Arquivo de configuração do Love2D (tamanho da janela, título, etc.).
├── assets/               # Contém todos os recursos visuais e sonoros do jogo.
│   ├── images/           # Imagens de sprites, backgrounds, UI.
│   ├── sounds/           # Efeitos sonoros.
│   └── music/            # Trilhas sonoras.
├── lib/                  # Bibliotecas externas de terceiros (hump, bump, jumper, anim8, etc.).
│   ├── hump/
│   ├── bump.lua
│   ├── jumper.lua
│   └── anim8.lua
├── src/                  # Código-fonte do jogo.
│   ├── states/           # Módulos para os diferentes estados do jogo (menu, gameplay, gameover).
│   │   ├── BaseState.lua # (Opcional) Classe base para estados.
│   │   ├── PlayState.lua
│   │   ├── MenuState.lua
│   │   └── GameOverState.lua
│   ├── entities/         # Módulos para as entidades do jogo (inimigos, soldados, estrutura defensiva).
│   │   ├── Enemy.lua
│   │   ├── Soldier.lua
│   │   └── DefensiveStructure.lua
│   ├── ui/               # Módulos para elementos da interface do usuário (botões, painéis, loja).
│   │   ├── Button.lua
│   │   └── Shop.lua
│   ├── systems/          # (Opcional) Módulos para sistemas específicos (e.g., collision system, wave system).
│   │   ├── WaveManager.lua
│   │   └── CollisionHandler.lua
│   ├── utils/            # Funções utilitárias e ajudantes.
│   │   └── math.lua
│   └── main_game.lua     # (Opcional) Orquestra a lógica principal do jogo, chamada de PlayState.
├── .gitignore            # Arquivo para o Git ignorar arquivos e pastas específicas.
└── README.md             # Este arquivo!
```

-----

## 🤝 Contribuição e Boas Práticas Git

Adotamos um fluxo de trabalho de *feature branching* com foco em colaboração e testes contínuos.

### Fluxo de Trabalho de Branches

  * **`main`**: Esta é a branch principal e deve sempre conter uma versão **estável e jogável** do jogo. Nenhuma alteração é feita diretamente aqui.
  * **`develop`**: Esta branch integra todas as novas funcionalidades e correções de *bugs* que estão em desenvolvimento. É a base para a criação de novas *feature branches*.
  * **`feature/nome-da-feature`**: Para cada nova funcionalidade (ex: `feature/sistema-de-loja`, `feature/inimigos-variados`), uma nova branch deve ser criada a partir de `develop`.
  * **`bugfix/nome-do-bug`**: Para correções de *bugs* específicos (ex: `bugfix/colisao-inimigo`), uma nova branch deve ser criada a partir de `develop` (ou `main` para *hotfixes* críticos).

### Boas Práticas

1.  **Mantenha suas branches atualizadas:** Antes de começar a trabalhar, puxe as últimas alterações da `develop` para a sua *feature branch*.
    ```bash
    git checkout develop
    git pull origin develop
    git checkout -b feature/sua-nova-feature # Cria e muda para a nova branch
    ```
2.  **Commits Atômicos e Descritivos:** Faça commits pequenos e focados em uma única mudança ou funcionalidade. A mensagem do commit deve ser clara e concisa, explicando o que foi feito.
      * **BOM:** `feat: Adiciona sistema de compra de soldados na loja`
      * **RUIM:** `fix: Arruma umas coisas`
3.  **Testes Locais:** Sempre teste suas alterações na sua *feature branch* antes de submeter um `Pull Request`.
4.  **Pull Requests (PRs):**
      * Quando sua *feature* ou *bugfix* estiver completa e testada, crie um `Pull Request` da sua `feature branch` para a `develop` (ou `main` em casos de *hotfix*).
      * Descreva detalhadamente o que foi implementado/corrigido e como testar.
      * **Requer Revisão:** Pelo menos um membro da equipe deve revisar e aprovar o PR antes que ele seja mesclado.
5.  **Resolução de Conflitos:** É comum surgirem conflitos de mesclagem. Resolva-os cuidadosamente, comunicando-se com o colega que fez as alterações conflitantes.

-----

## 🛠️ Tecnologias e Ferramentas

  * **Engine:** [Love2D](https://love2d.org/)
  * **Linguagem de Programação:** [Lua](https://www.lua.org/)
  * **Controle de Versão:** [Git](https://git-scm.com/) e [GitHub](https://github.com/)
  * **Bibliotecas Externas (Love2D):**
      * **[hump.gamestate](https://github.com/vrld/hump)**: Gerenciamento de estados do jogo.
      * **[bump](https://github.com/kikito/bump.lua)**: Biblioteca de colisão 2D.
      * **[jumper](https://github.com/Yonaba/Jumper)**: Biblioteca de *pathfinding* (algoritmo A\*).
      * **[anim8](https://github.com/kikito/anim8)**: Gerenciamento de animações por *spritesheet*.
      * **[Guified](https://www.google.com/search?q=https://github.com/rxi/guified)** ou **[Slab](https://www.google.com/search?q=https://github.com/rxi/slab)**: (A ser definida pela equipe) Biblioteca para elementos de UI.

-----

## 👨‍💻 Equipe de Desenvolvimento

Este projeto está sendo desenvolvido por:

  * **Felipe Fagundes (https://github.com/FelipeFagundesCosta)** 
  * **Gabriel Silva (https://github.com/mathyc0de)** 
  * **Matheus Pimenta (https://github.com/mathyc0de)** 
  * **Pedro Caurio (https://github.com/PedroCaurio)** 

-----

## 🗓️ Cronograma e Metas (4 Semanas)

Adotamos uma abordagem ágil (Scrum/Kanban) para gerenciar o projeto dentro do prazo.

  * **Semana 1: Fundamentos e Estrutura**

      * Configuração do ambiente e Git.
      * Estrutura básica do projeto Love2D.
      * Entidade `DefensiveStructure` (HP, desenho).
      * Entidade `Enemy` (HP, movimento linear simples).
      * **Meta:** Inimigo se movendo em direção à estrutura e ambos com HP.

  * **Semana 2: UI, Economia e Combate Básico (MVP)**

      * Integração da biblioteca de colisão (`bump`).
      * UI básica (dinheiro, horda).
      * Sistema de Loja (botões, compra de soldados/melhorias).
      * Entidade `Soldier` (movimento, ataque).
      * Lógica de dano entre inimigos/soldados e inimigos/estrutura.
      * **Meta:** Jogo minimamente jogável com compra de soldados e combate básico.

  * **Semana 3: Ondas, Pathfinding e Refinamento**

      * Sistema de ondas de inimigos.
      * Integração da biblioteca de *pathfinding* (`jumper`) para inimigos.
      * Diferentes tipos de inimigos.
      * Refinamento das mecânicas existentes.
      * **Meta:** Inimigos seguindo um caminho complexo, jogo com progressão de hordas.

  * **Semana 4: Polimento, Áudio e Finalização**

      * Gerenciamento de estados (`hump.gamestate`) (menu, game over).
      * Integração de áudio (música e SFX).
      * Animações simples e efeitos visuais básicos.
      * Otimização de desempenho e correção de *bugs*.
      * **Meta:** Jogo completo, polido e pronto para entrega.

-----

## 📝 Licença

Este projeto é open-source e está licenciado sob a [MIT License](https://www.google.com/search?q=LICENSE).

-----

## 🎉 Agradecimentos

Gostaríamos de agradecer à comunidade Love2D e aos desenvolvedores das bibliotecas utilizadas por tornarem o desenvolvimento de jogos tão acessível e divertido\!

-----