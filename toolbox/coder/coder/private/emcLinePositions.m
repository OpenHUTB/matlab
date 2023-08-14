function newlines=emcLinePositions(text)



    newlines=regexp(text,'\r\n|\n\r|\n|\r');