#include <iostream>
#include <string>

using namespace std;

extern "C" char* Solve(char* str);

int main() {
    char str[255];
    cin.getline(str, 255);
    cout << "Fitting pairs:\n";
    cout << Solve(str);
	return 0;
}