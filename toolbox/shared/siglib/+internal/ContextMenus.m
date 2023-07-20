classdef ContextMenus



    methods(Static)
        function hMenu=createContext(opts)




            args={'Parent',opts{1},...
            'Tag',opts{2},...
            'Label',opts{2},...
            'Callback',opts{3:end}};
            hMenu=uimenu(args{:});
        end

        function menuNChoices(targetObj,ht,str,strs,prop,val)
































            if iscell(prop)
                targetProp=prop{1};
                targetIdx=prop{2};
            else
                targetProp=prop;
                targetIdx=[];
            end
            if nargin>5
                targetVal=val;
            else
                targetVal=str;
            end



            sel=strcmpi(str,strs);
            assert(any(sel))
            set(ht,'Checked','off');
            set(ht(sel),'Checked','on');

            if~isempty(prop)
                if isempty(targetIdx)
                    targetObj.(targetProp)=targetVal;
                else
                    tp=targetObj.(targetProp);
                    if iscell(tp)

                        targetObj.(targetProp){targetIdx}=targetVal;
                    elseif ischar(tp)||(isstring(tp)&&isscalar(tp))


                        if targetIdx>1



                            tv=repmat({tp},1,targetIdx-1);
                            tv{targetIdx}=targetVal;
                            targetObj.(targetProp)=tv;
                        else
                            targetObj.(targetProp)=targetVal;
                        end
                    else

                        targetObj.(targetProp)(targetIdx)=targetVal;
                    end
                end
            end
        end

        function menuChecked(p,h,prop)
            isOff=strcmpi(h.Checked,'off');
            if isOff
                h.Checked='on';
                p.(prop)=true;
            else
                h.Checked='off';
                p.(prop)=false;
            end
        end

        function menuAuto(p,h,prop)
            isOff=strcmpi(h.Checked,'off');
            if isOff
                h.Checked='on';
                p.(prop)='auto';
            else
                h.Checked='off';
                p.(prop)='manual';
            end
        end

        function[hm,hp]=createContextSubmenu(targetObj,...
            make,addSeparator,hc,...
            menuLabel,enumStrs,prop,enumVals)



























































            haveEnumVals=nargin>7;
            if iscell(menuLabel)
                parentLabel=menuLabel{1};
                childLabel=menuLabel{2};
            else
                parentLabel=menuLabel;
                childLabel='';
            end




            noSubmenu=isempty(parentLabel);





            if iscell(prop)
                targetProp=prop{1};
                targetIdx=prop{2};
            else
                targetProp=prop;
                targetIdx=[];
            end

            if make
                if noSubmenu

                    hp=hc;
                else
                    opts={hc,parentLabel,[]};
                    if addSeparator
                        opts=[opts,'separator','on'];
                    end
                    hp=internal.ContextMenus.createContext(opts);
                end
                if~isempty(childLabel)
                    opts={hp,childLabel,[]};
                    if addSeparator&&noSubmenu
                        opts=[opts,'separator','on'];
                        addSeparator=false;
                        addSepToFirstChild=false;
                    else
                        addSepToFirstChild=true;
                    end
                    hchildtitle=internal.ContextMenus.createContext(opts);
                    hchildtitle.Enable='off';
                else
                    addSepToFirstChild=false;
                end
                N=numel(enumStrs);
                clear hm
                for i=1:N
                    opts={hp,enumStrs{i},''};
                    if i==1&&(noSubmenu&&addSeparator||~noSubmenu&&addSepToFirstChild)



                        opts=[opts,'separator','on'];%#ok<AGROW>
                    end
                    hm(i)=internal.ContextMenus.createContext(opts);%#ok<AGROW>
                end
                hm(1).UserData=hm;
                if haveEnumVals
                    createContextSubmenu_installCB(targetObj,hm,enumStrs,prop,enumVals);
                else
                    createContextSubmenu_installCB(targetObj,hm,enumStrs,prop);
                end
            else


                hp=[];
                if noSubmenu
                    ht=hc;
                else
                    ht=findobj(hc.Children,'flat','Label',parentLabel);
                end
                htc=findobj(ht.Children,'flat','Label',enumStrs{1});
                assert(~isempty(htc));
                hm=htc.UserData;






                if haveEnumVals
                    createContextSubmenu_installCB(targetObj,hm,enumStrs,prop,enumVals);
                else
                    createContextSubmenu_installCB(targetObj,hm,enumStrs,prop);
                end
            end





            if~isempty(targetProp)
                if ischar(targetProp)||(isstring(targetProp)&&isscalar(targetProp))






                    val=targetObj.(targetProp);
                    if~isempty(targetIdx)&&~ischar(val)&&~(isstring(val)&&isscalar(val))

                        idx=1+rem(targetIdx-1,numel(val));
                        if iscell(val)
                            val=val{idx};
                        else
                            val=val(idx);
                        end
                    end
                    if haveEnumVals
                        if ischar(val)||(isstring(val)&&isscalar(val))
                            sel=strcmpi(val,enumVals);
                        else

                            sel=val==enumVals;
                        end
                    else


                        if iscellstr(val)||isstring(val)
                            [~,idx]=ismember(val,enumStrs);
                            sel=false(size(enumStrs));
                            sel(idx)=true;
                        else
                            sel=strcmpi(val,enumStrs);
                        end
                    end
                    set(hm(sel),'Checked','on');
                    set(hm(~sel),'Checked','off');
                else



                    if haveEnumVals
                        feval(prop,targetObj,hm,'',enumStrs,enumVals);
                    else
                        feval(prop,targetObj,hm,'',enumStrs);
                    end
                end
            end
        end

        function ht=createContextMenuChecked(p,make,addSeparator,...
            hc,menuLabel,prop)









            if~isvalid(hc)
                return
            end

            if iscell(prop)
                targetObj=prop{1};
                targetProp=prop{2};
            else
                targetObj=p;
                targetProp=prop;
            end

            if make
                opts={hc,menuLabel,...
                @(h,~)internal.ContextMenus.menuChecked(targetObj,h,targetProp)};
                if addSeparator
                    opts=[opts,'separator','on'];
                end
                ht=internal.ContextMenus.createContext(opts);
            else
                ht=findobj(hc.Children,'flat','Label',menuLabel);
            end
            set(ht,'Checked',internal.LogicalToOnOff(targetObj.(targetProp)));
        end

        function createContextMenuAuto(p,make,addSeparator,...
            hc,menuLabel,propName)



            if make
                opts={hc,menuLabel,@(h,~)internal.ContextMenus.menuAuto(p,h,propName)};
                if addSeparator
                    opts=[opts,'separator','on'];
                end
                ht=internal.ContextMenus.createContext(opts);
            else
                ht=findobj(hc.Children,'flat','Label',menuLabel);
            end
            ht.Checked=internal.LogicalToOnOff(strcmpi(p.(propName),'auto'));
        end
    end
end





function createContextSubmenu_installCB(targetObj,hm,strs,prop,enumVals)


    N=numel(hm);
    haveEnumVals=nargin>4;

    if isa(prop,'function_handle')





        for i=1:N
            if haveEnumVals
                hm(i).Callback=@(~,~)feval(prop,targetObj,hm,strs{i},strs,enumVals);
            else
                hm(i).Callback=@(~,~)feval(prop,targetObj,hm,strs{i},strs);
            end
        end
    else


        if haveEnumVals
            for i=1:N

                if iscell(enumVals)
                    enumVals_i=enumVals{i};
                else
                    enumVals_i=enumVals(i);
                end
                hm(i).Callback=@(~,~)internal.ContextMenus.menuNChoices(targetObj,...
                hm,strs{i},strs,prop,enumVals_i);
            end
        else
            for i=1:N
                hm(i).Callback=@(~,~)internal.ContextMenus.menuNChoices(targetObj,...
                hm,strs{i},strs,prop);
            end
        end
    end

end
