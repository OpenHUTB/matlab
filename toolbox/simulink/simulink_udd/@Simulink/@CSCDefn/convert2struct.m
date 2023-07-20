function theStruct=convert2struct(hObj)




    theStruct=l_convert2struct(hObj);



    theStruct.MSPackage=theStruct.OwnerPackage;




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


            if isscalar(thisValue)&&isequal(classOfValue,'string')
                thisValue=char(thisValue);
                classOfValue=class(thisValue);
            end



            if ismember(classOfValue,{'double','int32','logical'})

            elseif isequal(classOfValue,'char')

                thisValue=strrep(thisValue,'"','\"');
                thisValue=strrep(thisValue,'%<','\%<');
                thisValue=strrep(thisValue,newline,' ');

            elseif(Simulink.data.getScalarObjectLevel(thisValue)>0)

                thisValue=l_convert2struct(thisValue);
            else

                assert(isa(hObj,'Simulink.CustomStorageClassAttributes'));
                MSLDiagnostic('RTW:tlc:CannotPassCustomAttributeToTLC',...
                thisName,class(thisValue)).reportAsWarning;
                theStruct=rmfield(theStruct,thisName);
                continue;
            end

            theStruct.(thisName)=thisValue;
        end


