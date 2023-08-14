function p=getParamData(obj,name,varargin)






    tlc=obj.tlcInfo;
    if~isempty(tlc)
        sname=configset.internal.util.toShortName(name);
        if tlc.isKey(sname)
            p=tlc(sname);
            return;
        end
    end

    if nargin>=3
        mcs=varargin{1};
    else
        mcs=configset.internal.getConfigSetStaticData;
    end

    if nargin>=4
        cs=varargin{2};
    else
        cs=obj.Source;
    end

    if nargin>=5
        testParamName=varargin{3};
    else
        testParamName=true;
    end


    if~testParamName||mcs.isValidParam(name)
        p=mcs.getParam(name,testParamName);
    else
        p=[];
        return;
    end





    if iscell(p)
        owner=obj.getParamOwner(name,cs,name);
        if isempty(owner)
            p=[];
            return;
        end


        if isa(owner,'Simulink.STFCustomTargetCC')
            mcp=mcs.getComponent('Target');
        else
            mcp=mcs.getComponent(class(owner));
        end
        if isempty(mcp)

            p=[];
        elseif mcp.isValidParam(name)

            p=mcp.getParam(name);
        elseif strcmp(mcp.Type,'Target')

            mcp=mcs.getComponent('Target');
            if mcp.isValidParam(name)
                p=mcp.getParam(name);
            else
                p=[];
            end
        else
            p=[];
        end
    end




    if~isempty(p)&&strcmp(p.Component,'CPPClassGenComp')
        if~cs.isValidParam(p.Name)
            p=[];
        end
    end





