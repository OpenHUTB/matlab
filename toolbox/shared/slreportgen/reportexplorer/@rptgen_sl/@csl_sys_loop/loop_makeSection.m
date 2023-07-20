function loop_makeSection(this,d,varargin)







    if~isempty(varargin)
        attList=varargin{:};
    else
        attList={};
    end

    if this.HierarchicalSectionNumbering
        currSys=this.RuntimeCurrentObject;
        sysObj=get_param(currSys,'Object');
        sysList=strrep(this.RuntimeLoopObjects,newline,' ');
        oString=locGetOrderString(this,sysObj,sysList);
        if~isempty(oString)
            attList={'label',oString};
        end
    end
    this.makeSection(d,attList);


    function oString=locGetOrderString(this,sysObj,sysList,varargin)

        persistent HIER_PREFIX_MAP

        if isempty(varargin)
            mode="";
        else
            mode=varargin{1};
        end

        if strcmp(mode,"reset")
            HIER_PREFIX_MAP=[];
            return;
        end


        if isempty(HIER_PREFIX_MAP)
            HIER_PREFIX_MAP=containers.Map();

            this.RuntimeCleanupFcns{end+1}=@()locGetOrderString([],[],[],'reset');


            stack=[];
            clevel=0;
            sortedSysList=sort(sysList);
            n=numel(sortedSysList);
            for i=1:n
                sysPath=sortedSysList{i};
                dlevel=numel(slreportgen.utils.pathSplit(sysPath));

                if(dlevel>clevel)
                    while((dlevel-clevel)>0)
                        stack(end+1)=1;%#ok
                        clevel=clevel+1;
                    end
                else
                    while((clevel-dlevel)>0)
                        stack(end)=[];
                        clevel=clevel-1;
                    end
                    stack(end)=stack(end)+1;
                end
                HIER_PREFIX_MAP(sysPath)=strjoin(string(stack),".");
            end
        end

        sys=strrep(getFullName(sysObj),newline,' ');
        if isKey(HIER_PREFIX_MAP,sys)
            oString=char(HIER_PREFIX_MAP(sys));
        else
            oString='';
        end

