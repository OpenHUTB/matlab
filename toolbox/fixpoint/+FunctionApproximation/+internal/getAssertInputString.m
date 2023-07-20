function assertInputString=getAssertInputString(numInputs)





    assertInputString='';
    if numInputs>1
        sizeOfinputString=convertStringsToChars(strings(numInputs,1));
        sizeOfinputString{1}='(size(inputValues1) == size(inputValues2))';

        for i=2:numInputs-1
            sizeOfinputString{i}=[' & (size(inputValues',num2str(i),') == size(inputValues',num2str(i+1),'))'];
        end
        sizeOfinputString=[sizeOfinputString{:}];
        assertInputString=[newline,'assert(all(',sizeOfinputString,'));',newline];
    end
end