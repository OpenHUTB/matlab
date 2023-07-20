function inserted=insertInCell(hDoc,targetCell,varargin)




    inserted=false;


    ctrlWidth=15;
    ctrlHeight=15;
    ctrlLeft=targetCell.left+targetCell.width-ctrlWidth;
    ctrlTop=targetCell.top+targetCell.height-ctrlHeight;
    count=rmiref.ExcelUtil.insertions('count',sprintf('r%dc%d',targetCell.Row,targetCell.Column));
    if count>0
        ctrlLeft=ctrlLeft-ctrlWidth*count;

    end


    if length(varargin)==1

        [navcmd,dispstr]=rmi.objinfo(varargin{1});

        [useMatlabConnector,actxId,customBitmap]=rmiref.cachedSettings('get');
    else
        navcmd=varargin{1};
        dispstr=varargin{2};
        if length(varargin)>2
            forceHTLinks=varargin{3};
        else
            forceHTLinks=false;
        end
        if forceHTLinks

            useMatlabConnector=true;
            customBitmap=rmipref('LinkIconFilePath');
        else


            [useMatlabConnector,actxId,customBitmap]=rmiref.cachedSettings('get');
        end
    end

    if useMatlabConnector
        url=rmiut.cmdToUrl(navcmd);
        if isempty(url)

            return;
        end
        if~isempty(customBitmap)&&exist(customBitmap,'file')==2
            pictureFile=customBitmap;
        else
            pictureFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwlink.bmp');
        end
        try
            newShape=hDoc.ActiveSheet.Shapes.AddPicture(pictureFile,0,1,ctrlLeft,ctrlTop,ctrlWidth,ctrlHeight);
            hDoc.ActiveSheet.Hyperlinks.Add(newShape,url,'',dispstr);
            inserted=true;
            rmiref.ExcelUtil.insertions('store',sprintf('r%dc%d',targetCell.Row,targetCell.Column));
        catch Mex
            errordlg({...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:HyperlinkFailedToInsert')),...
            Mex.message},...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:LinkProblem')));
        end
    elseif~isempty(actxId)
        try

            oleObject=hDoc.ActiveSheet.OLEObjects.Add(actxId,...
            '',0,0,'',0,'',...
            ctrlLeft,ctrlTop,ctrlWidth,ctrlHeight);

            slrefobj=oleObject.object;
            slrefobj.ToolTipString=dispstr;
            slrefobj.MLEvalString=navcmd;

            oleObject.Visible=0;
            oleObject.Visible=1;
            inserted=true;
            rmiref.ExcelUtil.insertions('store',sprintf('r%dc%d',targetCell.Row,targetCell.Column));
            if~isempty(customBitmap)
                rmiref.actx_picture(slrefobj,customBitmap);
            end
        catch Mex
            errordlg({...
            getString(message('Slvnv:rmiref:ExcelUtil:FailedToInsert',hDoc.FullName)),...
            Mex.message,...
            getString(message('Slvnv:rmiref:ExcelUtil:MakeSureActxEnabled'))},...
            getString(message('Slvnv:rmiref:ExcelUtil:RequirementsLinkProblem')));
        end
    else
        warning(message('Slvnv:rmiref:ExcelUtil:insertInCell','SLRefButton'));
    end
end
