




function[createdTempLib]=createLibraryCopy(inputLib)

    createdTempLib=[tempname,'.slx'];
    close_system(inputLib,createdTempLib);
end
