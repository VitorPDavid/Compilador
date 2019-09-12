# locais dos arquivos #
SRC = ./src

# compilador usado #
CC = g++

# qual o nome do arquivo criado #
MAIN = compilador

# o arquivo de entrada #
ENT = teste.txt

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


# Cria os arquivos intermediarios #
$(SRC)/lex.yy.c: $(SRC)/lexico.l
	@lex -o $@ $<

$(SRC)/y.tab.c: $(SRC)/sintatico.y
	@yacc -d -o $@ $<

# compila tudo e cria o compilador #
$(MAIN): $(SRC)/y.tab.c $(SRC)/lex.yy.c
	@$(CC) -o $(MAIN) $< $(FLAGS) $(LIBS)


limpar: clean
	@echo "Arquivos desnecessarios retirados"


# executa o programa #
run:
	-@./$(MAIN) < $(ENT)

clean:
	@rm -rf $(SRC)/*.c
	@rm -rf $(SRC)/*.h

# limpa o executavel #
clean-all: clean
	@rm -rf ./$(MAIN)
