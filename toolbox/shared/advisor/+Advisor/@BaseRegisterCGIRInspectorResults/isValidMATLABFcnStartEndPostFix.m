function isValid=isValidMATLABFcnStartEndPostFix(str)








    isValid=false;

    pos=strsplit(str,'-');
    if numel(pos)==2
        startPos=str2double(pos{1});
        endPos=str2double(pos{2});

        if startPos>0&&startPos<endPos
            isValid=true;
        end
    end
end
