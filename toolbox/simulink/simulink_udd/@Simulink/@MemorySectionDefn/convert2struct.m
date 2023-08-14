function theStruct=convert2struct(hObj)




    theStruct=l_convert2struct(hObj);


    theStruct=rmfield(theStruct,{'CommentForUI','PrePragmaForUI','PostPragmaForUI'});




    function theStruct=l_convert2struct(hObj)

        theStruct=[];
        if isempty(hObj)
            return;
        end


        theStruct=get(hObj);


        fnames=fieldnames(theStruct);
        for i=1:length(fnames)
            thisName=fnames{i};
            thisValue=theStruct.(thisName);
            classOfValue=class(thisValue);

            if isequal(classOfValue,'char')

                thisValue=strrep(thisValue,'"','\"');
                thisValue=strrep(thisValue,'%<','\%<');
                thisValue=strrep(thisValue,newline,' ');
            elseif(Simulink.data.getScalarObjectLevel(thisValue)>0)

                thisValue=l_convert2struct(thisValue);
            else
                assert(isequal(classOfValue,'logical'));
            end

            theStruct.(thisName)=thisValue;
        end




