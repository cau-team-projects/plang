#include<stdio.h>
#include<stdlib.h>

int main(void){
	int array1[10] = { 1,2,3,4,5,6,7,8,9 }, i = 0, k = 0, l = 0;
	float array2[10] = { 1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9 }, array3[10] = {};
	while (i < 10){
		if (i == 4){
			printf("%d is 5th element of array\n", array1[i]);
		}
		else if (i <= 2){
			printf("first three is unknown\n");
		}
		else if (i >= 7){
			printf("last two is also unknown\n");
		}
		else{
			printf("%d\n", array1[i]);
		}
	}
	for (int j = 0; j < 10; j++){
		array3[j] = array2[j];
		if (j != 3){
			continue;
		}
		else{
			printf("4th element is copied!\n");
		}
	}
	printf("5+3-6/7*4 is %f", 5 + 3 - 6 / 7 * 4);
	while (!k){
		l++;
		if (l = 50){
			printf("l is 50\n");
			k = 1;
		}
	}
	return 0;
}
//test data for bad case.
//this version has different form from user.
//no new line with use of {}
//same type definition use same line.