# locais dos arquivos #
SRC = ./src

# compilador usado #
CC = g++

# nome dos arquivos utilizados #
LEX = lexico.l
SINT = sintatico.y

# qual o nome do arquivo criado #
MAIN = compilador

# o arquivo de entrada #
ENT = teste.ks

# arquivo de saida #
SAIDA = saida.cpp
EXECSAIDA = saida

# Flasg de compilação #
FLAGS = -O3 #-Wall

# Bicliotecas extras #
LIBS = -ll

# rodando o make executa o projeto #
all: comeco lexico sintatico projeto limpar

# rodando e executando
kek: all run

# indica que iniciou a compilação #
comeco:
	@echo "Criando o compilador"

# cria a biblioteca que sera usada #
lexico: $(SRC)/lex.yy.c
	@echo "lexico criado"

sintatico: $(SRC)/y.tab.c
	@echo "Sintatico criado"

# compila o programa tendo a biblioteca #
projeto: $(MAIN)
	@echo "Fim da criação"

limpar: clean
	@echo "Arquivos desnecessarios retirados"

# Cria os arquivos intermediarios #
$(SRC)/lex.yy.c: $(SRC)/$(LEX)
	@lex -o $@ $<

$(SRC)/y.tab.c: $(SRC)/$(SINT)
	@yacc -d -o $@ $<

# compila tudo e cria o compilador #
$(MAIN): $(SRC)/y.tab.c $(SRC)/lex.yy.c
	@$(CC) -o $(MAIN) $< $(FLAGS) $(LIBS)

# executa o programa #
run:
	-@./$(MAIN) < $(ENT)

create-saida:
	-@./$(MAIN) < $(ENT) > $(SAIDA)

run-saida: $(SAIDA)
	-@$(CC) -o $(EXECSAIDA) $(SAIDA) $(FLAGS)
	-@./$(EXECSAIDA)

clean:
	@rm -rf $(SRC)/*.c
	@rm -rf $(SRC)/*.h

# limpa o executavel #
clean-all: clean
	@rm -rf ./$(MAIN)
