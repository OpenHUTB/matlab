
function feObj=instanceMap(uuid,instance)




    persistent filterExplorerInstance;
    try
        feObj=[];
        if nargin<1

            if~isempty(filterExplorerInstance)
                feObj=[filterExplorerInstance.instance];
            end
        elseif nargin==1
            if strcmpi(uuid,'reset')
                filterExplorerInstance=[];
                return;
            elseif~isempty(filterExplorerInstance)
                fn=filterExplorerInstance({filterExplorerInstance.uuid}==string(uuid));
                if~isempty(fn)
                    feObj=fn.instance;
                end
            end
        else
            feObj=instance;
            if isempty(filterExplorerInstance)
                filterExplorerInstance=struct('uuid',uuid,'instance',feObj);
            else
                fidx=find({filterExplorerInstance.uuid}==string(uuid));
                if~isempty(fidx)
                    filterExplorerInstance(fidx).instance=feObj;
                else
                    filterExplorerInstance(end+1)=struct('uuid',uuid,'instance',feObj);
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end
end

