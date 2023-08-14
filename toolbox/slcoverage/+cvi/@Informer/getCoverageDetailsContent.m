function[urlStr,htmlStr]=getCoverageDetailsContent(this,modelH,covMode,selectionH,useModelAsFallback)













    if nargin<4
        selectionH=modelH;
    end
    if nargin<5
        useModelAsFallback=false;
    end

    urlStr='';
    htmlStr='';
    modelName=get_param(modelH,'name');

    selectionCvId=getCoverageId(this,modelH,selectionH);
    if useModelAsFallback&&(selectionCvId==0)
        selectionCvId=getCoverageId(this,modelH);
    end

    report=this.reportManager.getReport(modelH,selectionH,covMode);
    if numel(report)==1&&((getCoverageId(this,modelH)==selectionCvId)||...
        ((selectionCvId>0)||useModelAsFallback))
        urlStr=getUrl(report.reportPathEncoded,selectionCvId);
    end

    if isempty(urlStr)
        htmlStr=NoCoverageHtmlStr(modelName,covMode,this.reportManager.hasMultipleCovModes);
    end
end

function cvId=getCoverageId(infrmObj,modelH,selectionH)
    if nargin<3
        selectionH=modelH;
    end

    cvId=0;
    badgeHandler=infrmObj.findBadgeHandler(modelH);
    if~isempty(badgeHandler)
        for i=1:length(selectionH)
            cvId=badgeHandler.getCvId(selectionH(i));
            if(cvId>0)
                return;
            end
        end
    end
end

function urlStr=getUrl(reportPath,cvId)
    if(cvId==0)
        refName='';
    else
        refName=sprintf('#refobj%d',cvId);
    end
    urlStr=['file:///',strrep(reportPath,'\','/'),refName];
end

function htmlStr=NoCoverageHtmlStr(modelName,covType,hasMultipleCovModes)

    if hasMultipleCovModes
        msgText=getString(message('Slvnv:simcoverage:cvmodelview:NoCovDetailsForSimMode',covType,modelName));
    else
        msgText=getString(message('Slvnv:simcoverage:cvmodelview:NoCovDetails',modelName));
    end

    htmlStr=[
    '<table height=75%>',10...
    ,'<tr> <td valign=middle align=center><p>',10...
    ,msgText,10...
    ,'</p></td> </tr>',10...
    ,'</table>',10...
    ];
end
