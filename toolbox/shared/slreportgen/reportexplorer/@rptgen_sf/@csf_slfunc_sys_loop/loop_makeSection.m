function loop_makeSection(this,d,varargin)







    if~isempty(varargin)
        attList=varargin{:};
    else
        attList={};
    end

    if this.HierarchicalSectionNumbering
        currSys=this.RuntimeCurrentObject;
        sysObj=get_param(currSys,'object');
        sysList=strrep(this.RuntimeLoopObjects,sprintf('\n'),' ');
        oString=locGetOrderString(sysObj,sysList);
        if~isempty(oString)
            attList={'label',oString};
        end
    end
    this.makeSection(d,attList);


    function oString=locGetOrderString(sys,sysList)


        idx=1;
        if isa(sys,'handle.handle')
            leftSys=sys.left;
        else
            leftSys=sys.getPrevious;
        end

        while~isempty(leftSys)
            if isa(leftSys,'Simulink.SubSystem')
                name=regexprep(leftSys.getFullName(),'\n',' ');
                if any(strcmp(sysList,name))
                    idx=idx+1;
                end
            end
            if isa(leftSys,'handle.handle')
                leftSys=leftSys.left;
            else
                leftSys=leftSys.getPrevious;
            end
        end

        if isempty(sys.up)||isa(sys.up,'Simulink.Root')
            oString=sprintf('%i',idx);
        else
            oString=sprintf('%s.%i',...
            locGetOrderString(sys.up,sysList),...
            idx);
        end

