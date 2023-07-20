function[ev,title]=getContent(h,v)













    if nargin<2
        v=h.Source;
    end

    if ischar(v)&&size(v,1)==1&&~contains(v,newline)
        try
            ev=getValue(h,v);
            title=getValue(h,h.TableTitle);

            d=get(rptgen.appdata_rg,'CurrentDocument');
            if~isempty(ev)
                ev=convertToLink(d,ev);
            end
        catch
            error(message('Sldv:RptGen:MissingVar',v));
        end
    end
    function ev=getValue(h,str)
        ev=[];
        if isempty(str)
            return;
        end
        try
            bev=evalin('base',str);
            if isMap(bev)
                h=getLooper(h);
                obj=h.RuntimeCurrentObject;
                ev=sfslLookup(bev,obj);
                bev.remove(obj);
            else
                ci=getCurrLoopIdx(h);
                ev=getIdxValue(h,bev,ci);
            end
        catch Mex %#ok<NASGU>
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



                            function h=getLooper(h)
                                if~ishandle(h)
                                    h=[];
                                elseif isempty(findprop(h,'RuntimeCurrentObject'))
                                    h=getLooper(h.up);
                                end
                                return;

                                function v=convertToLink(d,v)

                                    if isstruct(v)
                                        if isfield(v,'rpt_link_type')
                                            linkType=v.rpt_link_type;
                                            linkID=v.rpt_link_id;
                                            linkText=v.rpt_link_text;
                                            v=makeLink(d,linkID,linkText,linkType);
                                        else
                                            f=fieldnames(v);
                                            for eIdx=1:numel(v)
                                                for fidx=1:length(f)
                                                    cfv=getfield(v(eIdx),f{fidx});%#ok<GFLD>
                                                    if iscell(cfv)||isstruct(cfv)
                                                        nfv=convertToLink(d,cfv);
                                                        v=setfield(v(eIdx),f{fidx},nfv);
                                                    end
                                                end
                                            end
                                        end
                                    elseif iscell(v)
                                        [n,m]=size(v);
                                        for i=1:n
                                            for j=1:m
                                                v{i,j}=convertToLink(d,v{i,j});
                                            end
                                        end
                                    end





