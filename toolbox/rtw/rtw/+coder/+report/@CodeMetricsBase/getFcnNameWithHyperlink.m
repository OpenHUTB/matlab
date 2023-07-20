function txt=getFcnNameWithHyperlink(obj,fcn)



    isForNewReport=obj.isSLReportV2;
    ccm=obj.Data;
    txt=fcn;
    if ccm.FcnInfoMap.isKey(fcn)
        aElement=Advisor.Element;
        aElement.setTag('span');

        if ccm.FcnInfoMap(fcn).IsStatic
            fcnName=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(ccm.FcnInfoMap(fcn).Name);
        else
            fcnName=fcn;
        end
        if obj.getGenHyperlinkFlag()&&ccm.FcnInfoMap(fcn).HasDefinition
            fullFileName=ccm.FcnInfoMap(fcn).File;

            aElement.setTag('a');
            if~isForNewReport


                fName=fcnName;

                classSep=strfind(fcnName,'::');
                if~isempty(classSep)
                    fName=fcnName(classSep(end)+2:end);
                end
                tmp=obj.getLinkManager();
                htmlfileFullName=tmp.getHTMLFileName(fullFileName);

                if~obj.htmlfileExistMap.isKey(htmlfileFullName)
                    obj.htmlfileExistMap(htmlfileFullName)=exist(htmlfileFullName,'file');
                end
                if obj.forceGenHyperlinkToSource||obj.htmlfileExistMap(htmlfileFullName)
                    htmlfilename=obj.getLinkToFile(fullFileName);
                    if~isempty(htmlfilename)
                        aElement.setAttribute('href',[htmlfilename,'#fcn_',fName]);
                        aElement.setAttribute('title',fcnName);
                        aElement.setAttribute('class','code2code');
                    end
                end
            else


                if isprop(ccm,'ClassMemberInfo')&&~isempty(ccm.ClassMemberInfo)&&isfield(ccm.ClassMemberInfo,'Name')...
                    &&length(ccm.ClassMemberInfo)>=1
                    if length(ccm.ClassMemberInfo)==1
                        className=ccm.ClassMemberInfo.Name;
                    else
                        names={ccm.ClassMemberInfo.Name};
                        vec=contains(names,'ModelClass');
                        if any(vec)
                            [~,idx]=max(vec);
                            className=ccm.ClassMemberInfo(idx).Name;
                        else
                            className='';
                        end
                    end

                    regexpStr=sprintf('%s::~*?%s$',className,className);
                    if~isempty(regexp(fcnName,regexpStr,'match'))


                        fname=className;
                    else
                        fname=fcnName;
                    end
                else
                    fname=fcnName;
                end

                aElement.setAttribute('href','javascript: void(0)');
                aElement.setAttribute('onclick',coder.report.internal.getPostParentWindowMessageCall('jumpToCode',fname));
            end
        end

        aElement.setContent(fcnName);
        title=obj.getFunctionTitle(fcn,fcnName);
        if~isempty(title)
            aElement.setAttribute('title',title);
        end
        txt=aElement.emitHTML;
    end
end


