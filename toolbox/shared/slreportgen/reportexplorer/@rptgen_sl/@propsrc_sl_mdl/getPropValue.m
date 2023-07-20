function[pValue,propName]=getPropValue(this,objList,propName)




    if ischar(objList)
        objList={objList};
    end

    switch propName
    case this.getCommonPropValue('PropList')



        [pValue,propName]=getCommonPropValue(this,objList,propName);

    case this.getPropList('rtwsummary')
        pValue=locRtwSummary(objList,propName);

    case 'ModifiedHistory'
        pValue=locModifiedHistory(objList);

    otherwise
        pValue=rptgen.safeGet(objList,propName,'get_param');
    end

    function out=locModifiedHistory(objList)

        d=get(rptgen.appdata_rg,'CurrentDocument');

        n=numel(objList);
        out=cell(1,n);
        for i=1:n
            modifiedHistory=get_param(objList{i},'ModifiedHistory');
            element=createElement(d,'programlisting',modifiedHistory);
            setAttribute(element,'xml:space','preserve');
            out{i}=element;
        end


        function out=locRtwSummary(mdl,prop)

            adSL=rptgen_sl.appdata_sl;

            for i=length(mdl):-1:1
                fid=get_rtw_fid(adSL,mdl{i});
                if(fid>0)
                    out{i,1}=locRtwParser(fid,prop);
                    fclose(fid);
                else
                    out{i,1}='N/A';
                end
            end


            function pVal=locRtwParser(fid,propName)

                pVal='N/A';
                lenPropName=length(propName);
                while true
                    s=fgetl(fid);
                    if~ischar(s)
                        break;
                    else
                        s=trimString(s);
                        if strncmpi(s,propName,lenPropName)
                            pVal=trimString(s(lenPropName+1:end));
                            break;
                        end
                    end
                end


                function s=trimString(s)


                    [~,c]=find((s~=0)&~isspace(s));
                    if isempty(c)
                        s=s([]);
                    else
                        s=s(:,min(c):max(c));
                    end
