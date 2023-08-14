function enumClassNames=findEnumTypes(source,varargin)




















    enumClassNames={};


    sourceExistsStatus=exist(source,'file');
    if sourceExistsStatus==4



        bCloseSys=false;
        if~bdIsLoaded(source)
            load_system(source);
            bCloseSys=true;
        end


        enumClassNames=Simulink.data.internal.findModelEnums(...
        source,loc_SearchRefModels(varargin));


        if bCloseSys
            close_system(source,0);
        end



    else


        try
            ddConn=Simulink.dd.open(source);
        catch
            ddConn=[];
        end
        if~isempty(ddConn)&&ddConn.isOpen


            enumClassNames=ddConn.getEnumeratedTypeDependencies;
        end
    end

end


function ret=loc_SearchRefModels(optionArgs)
    ret=false;

    numOptionArgs=length(optionArgs);
    if(numOptionArgs<2)||(mod(numOptionArgs,2)~=0)
        return;
    end

    PVPairIndex=1;


    while PVPairIndex<=numOptionArgs
        if ischar(optionArgs{PVPairIndex})&&...
            strcmpi(optionArgs{PVPairIndex},'SearchReferencedModels')
            optVal=optionArgs{PVPairIndex+1};
            switch class(optVal)
            case 'double'
                ret=isscalar(optVal)&&optVal~=0;
            case 'logical'
                ret=isscalar(optVal)&&optVal;
            case 'char'
                ret=strcmpi(optVal,'on');
            otherwise

            end
            return;
        end
        PVPairIndex=PVPairIndex+2;
    end
end
