function logAssessmentsFromAssertionBlocks(state)









    try
        slfeature('VerifyResultForAssert',double(strcmp(state,'on')));
    catch ME
        disp(ME.message);
    end
end
