int a = 10;

def teste(int a, int d = 10, float f = 10.9, float o = 0.0) {
    output(a, d);

    def algo(float d) {
        output(10.5);
    }

    def algo(float b, int a) {
        output(10);
    }

    def algo(int a) {
        output(20);
    }

    def kek() => int {
        algo(3.8);
        return 10;
    }

    output(kek(), algo(3.8), algo(20));
}

def algo(float a) {
    output(a);
}

algo(20.0);
teste(a, 10);
