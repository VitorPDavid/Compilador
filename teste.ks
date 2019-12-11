int a = 10;

def teste(int a, int d = 10, float f = 10.9) => int{
    output(a,d,f);

    return 1;
}

int b = 15;
float c = 8.6;
c + teste(a,b,c);