function out=execute(h,d,varargin)






    out=[];

    v=h.FilterContainer;
    if ischar(v)&&size(v,1)==1&&isempty(findstr(v,char(10)))
        try
            ev=getValue(h,v);
            if isempty(ev)
                return;
            end
        catch
            error('Sldv:RptGen:MissingVar',getString(message('Sldv:RptSldv:Filter:execute:VariableDoesNotExist',v)));
        end
    end
    out=createDocumentFragment(d);
    if h.addAnchor
        currObj=getCurrObj(h);
        ps=rptgen_sf.propsrc_sf;

        if isa(currObj,'Stateflow.Chart')
            apDataSf=rptgen_sf.appdata_sf;
            currObj=apDataSf.CurrentChartBlock;
            ps=rptgen_sl.propsrc_sl;
        end

        out.appendChild(makeLinkScalar(ps,currObj,'','anchor',d,''));
    end
    h.runChildren(d,out);


    function ev=getValue(h,str)
        ev=[];
        if isempty(str)
            return;
        end
        try
            bev=evalin('base',str);
            if isMap(bev)
                obj=getCurrObj(h);
                ev=sfslLookup(bev,obj);
            else

            end
        catch
        end

        function val=sfslLookup(map,key)
            if ischar(key)
                val=map.lookup(key);
            else
                if hasProp(key,'Machine')&&hasProp(key,'Id')
                    val=map.lookup(getSFKey(key.Id));
                end
            end

            function key=getSFKey(objId)
                apDataSf=rptgen_sf.appdata_sf;
                blockH=apDataSf.CurrentChartBlock.Handle;
                [path,type,num]=sldvshareprivate('getSFObjPersistentId',objId,blockH);
                key=[path,'_',type,'_',num2str(num)];


                function bool=isMap(mh)

                    bool=false;
                    if ishandle(mh)
                        bool=hasMethod(mh,'lookup');
                    end

                    function bool=hasProp(h,propName)
                        bool=ishandle(h)&&~isempty(find(get(classhandle(h),'properties'),'Name',propName));

                        function bool=hasMethod(h,methodName)
                            bool=ishandle(h)&&~isempty(find(get(classhandle(h),'methods'),'Name',methodName));

                            function obj=getCurrObj(h)
                                h=getLooper(h);
                                obj=h.RuntimeCurrentObject;

                                function h=getLooper(h)
                                    if~ishandle(h)
                                        h=[];
                                    elseif isempty(findprop(h,'RuntimeCurrentObject'))
                                        h=getLooper(h.up);
                                    end
                                    return;


