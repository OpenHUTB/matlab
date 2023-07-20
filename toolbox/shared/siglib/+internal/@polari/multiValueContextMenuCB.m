function multiValueContextMenuCB(targetObj,hm,str,strs,datasetIdx,propName)



































    if isempty(str)



        val=targetObj.(propName);
        if iscell(val)
            if isempty(datasetIdx)



                str=targetObj.(propName);
                [~,i]=ismember(str,strs);
                sel=false(size(strs));
                sel(i)=true;
                set(hm(sel),'Checked','on');
                set(hm(~sel),'Checked','off');
                return
            else




                Nv=numel(val);
                i=1+rem(datasetIdx-1,Nv);
                str=val{i};
            end
        else
            str=val;
        end




        internal.ContextMenus.menuNChoices(targetObj,hm,str,strs,[]);
    else


        if~isempty(datasetIdx)
            val=targetObj.(propName);
            Nt=getNumDatasets(targetObj);
            if iscell(val)



                Nv=numel(val);
                if Nv<Nt
                    targetObj.(propName)=[val,val(1:Nt-Nv)];
                end
            else




                if Nt>1
                    targetObj.(propName)=repmat({val},1,Nt);
                end
            end
        end

        internal.ContextMenus.menuNChoices(targetObj,hm,...
        str,strs,{propName,datasetIdx});
    end
