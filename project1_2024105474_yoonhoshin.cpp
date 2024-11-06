#include <iostream>
#include <iomanip>
#include <cmath>

// print the matrix, use a window size of 3 and right align
void printMatrix(double** matrix, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n+1; j++)
            std::cout << std::setw(3) << matrix[i][j] << "\t";
        std::cout << std::endl;
    }
}

// Swap two rows of a matrix
void swapRows(double* row1, double* row2, int n) {
    double* temp = new double[n + 1];
    for (int i = 0; i < n + 1; i++) {
        temp[i] = row1[i];
        row1[i] = row2[i];
        row2[i] = temp[i];
    }
    delete[] temp;
}

void performGaussianElimination(double** matrix, int n) {
    if (matrix[0][0] == 0) {
        if (matrix[1][0] != 0)
            swapRows(matrix[0], matrix[1], n);
        else
            if (matrix[2][0] != 0)
                swapRows(matrix[0], matrix[2], n);
    }
    else
        swapRows(matrix[0], matrix[1], n);
    double num1, num2, num3;
    num1 = matrix[1][0] / matrix[0][0];
    for (int i = 0; i < n + 1; i++)
        matrix[1][i] -= num1 * matrix[0][i];
    num2 = matrix[2][0] / matrix[0][0];
    for (int i = 0; i < n + 1; i++)
        matrix[2][i] -= num2 * matrix[0][i];
    swapRows(matrix[1], matrix[2], n);
    num3 = matrix[2][1] / matrix[1][1];
    for (int i = 1; i < n + 1; i++)
        matrix[2][i] -= num3 * matrix[1][i];

    std::cout << "Gaussian Elimination result: the reduced row echelon form (RREF) matrix is" << std::endl;
    printMatrix(matrix, n);
}

void backSubstitution(double** matrix, int n, double* solution) {
    solution[2] = matrix[2][3] / matrix[2][2];
    solution[1] = (matrix[1][3] - (matrix[1][2] * solution[2])) / matrix[1][1];
    solution[0] = (matrix[0][3] - (matrix[0][2] * solution[2] + matrix[0][1] * solution[1])) / matrix[0][0];
}

void solveSystem(double** matrix, int n) {
    performGaussianElimination(matrix, n);
    double* solution = new double[n];
    backSubstitution(matrix, n, solution); // 뒤에서부터 값 도출

    std::cout << "The solution to the system of linear equations is:" << std::endl;
    std::cout << std::setprecision(6);
    for (int i = 0; i < n; i++) {
        std::cout << "x[" << i << "] = " << solution[i] << std::endl;
    }
    std::cout << std::endl;
    delete[] solution;
}

int main() {
    // create the augmented matrix
    int n = 3; // size of the matrix
    double** A = new double* [n];
    for (int i = 0; i < n; i++) {
        A[i] = new double[n + 1];
    }

    // initialize the matrix with values (does not require row exchange)
    A[0][0] = 2; A[0][1] = 3; A[0][2] = -1; A[0][3] = 1;
    A[1][0] = 4; A[1][1] = 4; A[1][2] = 3; A[1][3] = 3;
    A[2][0] = 2; A[2][1] = -3; A[2][2] = 1; A[2][3] = -1;

    // print original matrix
    std::cout << "The original matrix (the last column is augmented) is:" << std::endl;
    printMatrix(A, n);

    // solve the system of linear equations
    solveSystem(A, n);

    // initialize the matrix with values (requires row exchange)
    A[0][0] = 0; A[0][1] = 3; A[0][2] = -1; A[0][3] = 1;
    A[1][0] = 4; A[1][1] = 4; A[1][2] = 3; A[1][3] = 3;
    A[2][0] = 2; A[2][1] = -3; A[2][2] = 1; A[2][3] = -1;

    // print original matrix
    std::cout << "The original matrix (the last column is augmented) is:" << std::endl;
    printMatrix(A, n);

    // solve the system of linear equations
    solveSystem(A, n);

    // free the memory used by the matrix
    for (int i = 0; i < n; i++) {
        delete[] A[i];
    }
    delete[] A;

    return 0;
}
