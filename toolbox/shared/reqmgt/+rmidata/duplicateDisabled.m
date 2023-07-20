function duplicateDisabled(varargin)





    if nargin==0


        isFromLibrary();
        return;
    elseif ischar(varargin{1})

        diagName=varargin{1};
        isFromLibrary(diagName);
        return;
    end

    objH=varargin{1};
    srcSID=get_param(objH,'BlockCopiedFrom');



    if~isempty(srcSID)&&isFromLibrary(srcSID)


        rmidata.copyDisabled(objH,bdroot(objH),false,srcSID,true);



        if strcmp(get_param(objH,'BlockType'),'SubSystem')
            chartType=rmisf.sfBlockType(objH);
            if strcmp(chartType,'MATLAB Function')
                destSID=Simulink.ID.getSID(objH);
                rmidata.duplicateMLFB(srcSID,destSID,false);
            end
        end
    end
end

function varargout=isFromLibrary(sid)
    persistent libNameMap
    if isempty(libNameMap)||nargin==0
        libNameMap=containers.Map('KeyType','char','ValueType','logical');
        if nargin==0
            return;
        end
    end
    if any(sid==':')

        diagName=strtok(sid,':');
        if isKey(libNameMap,diagName)
            result=libNameMap(diagName);
        else
            try
                result=strcmp(get_param(diagName,'BlockDiagramType'),'library');
                libNameMap(diagName)=result;
            catch %#ok<CTCH>  



                result=false;
            end
        end
        varargout{1}=result;
    else


        if isKey(libNameMap,sid)
            remove(libNameMap,sid);
        end
    end
end


