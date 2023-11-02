#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv)
{
	if(setuid(0))
	{
		perror("setuid");
		exit(1);
	}

	if(setgid(0))
	{
		perror("setuid");
		exit(1);
	}

	if(execvp(argv[1], &argv[1]))
	{
		perror("execvp");
		exit(1);
	}

	return 0;
}
