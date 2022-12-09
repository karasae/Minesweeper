#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>

void showUserBoard(char *board, int h, int w);
void showPrivBoard(int **board, int h, int w);
int** genPrivBoard(int h, int w, int m, int initr, int initc);//rmember to do this after first reveal
void placeMines(int ** board, int h, int w, int m, int initr, int initc);

int main() {
    srand(time(0));
    int height, width, numMines, row, col;
    bool done = false, won = false;
    scanf("%d%d%d%d%d", &height, &width, &numMines, &row, &col);
    //printf("%d%d%c", height, width, '\n');
    char userBoard[height][width];
    for(int i=0; i<height; i++) {
        for(int j=0; j<width; j++) {
            userBoard[i][j] = '_';
        }
    }
    int **privBoard = genPrivBoard(height, width, numMines, row, col);
    showUserBoard((char*)userBoard, height, width);
    showPrivBoard((int**)privBoard, height, width);
    
    while(!done) {

    }

    return 0;
}

void showUserBoard(char *board, int h, int w) {
    for(int i=0; i<h; i++) {
        for(int j=0; j<w; j++) {
            printf("%c ", *((board+i*w)+j));
        }
        printf("%c", '\n');
    }
}

void showPrivBoard(int **board, int h, int w) {
    for(int i=0; i<h; i++) {
        for(int j=0; j<w; j++) {
            printf("%d ", board[i][j]);
        }
        printf("%c", '\n');
    }
}

int** genPrivBoard(int h, int w, int m, int initr, int initc) {
    int* values = calloc(h*w, sizeof(int));
    int** board = malloc(h*sizeof(int*));
    for(int i=0; i<h; i++) {
        board[i] = values + i*w;
    }

    for(int i=0; i<h; i++) {
        for(int j=0; j<w; j++) {
            board[i][j] = 0;
        }
    }
    placeMines(board, h, w, m, initr, initc);
    return board;
}

void placeMines(int ** board, int h, int w, int m, int initr, int initc) {
    int minesPlaced = 0;
    while(minesPlaced < m) {
        int row = rand()%h;
        int col = rand()%w;
        if(board[row][col]!=9 && (row < initr-1 || row > initr+1 || col < initc-1 || col > initc+1)) {
            board[row][col] = 9;
            for(int i=-1; i<=1; i++) {
                for(int j =-1; j<=1; j++) {
                    if((row+i>=0)&&(row+i<=h-1)&&(col+j>=0)&&(col+j<=w-1)&&(board[row+i][col+j]!= 9)) {
                        board[row+i][col+j]++;
                    }
                }
            }
            minesPlaced++;
        }
    }
}