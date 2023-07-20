function mFileName=cbkScript(this,saveDoc,mFileName)




    if~exist('saveDoc','var')
        saveDoc=this.getCurrentDoc();
    end

    if~exist('mFileName','var')

        defaultMFile=locGetDefaultMFile(saveDoc);
        [mFile,mPath]=uiputfile('*.m',getString(message('rptgen:RptgenML_Root:sprintf_GenerateMATLABFile')),defaultMFile);
        isCancelled=isequal(mFile,0)||isequal(mPath,0);
        mFileName=fullfile(mPath,mFile);
    else
        isCancelled=false;
        [mPath,mFile,mExt]=fileparts(mFileName);
        if isempty(mPath)
            mPath=pwd;
        end
        if isempty(mExt)
            mExt='.m';
        end
        mFileName=fullfile(mPath,[mFile,mExt]);
    end

    if~isCancelled

        [~,functionName]=fileparts(mFileName);
        if~isvarname(functionName)
            errordlg(...
            getString(message('rptgen:RptgenML_Root:invalidMATLABFileName')),...
            getString(message('rptgen:RptgenML_Root:sprintf_GenerateMATLABFile')));
        end

        if exist(mFileName,'file')
            [~,msg]=fileattrib(mFileName);
            isGenerate=msg.UserWrite;
        else
            isGenerate=true;
        end

        if isGenerate
            makemcode(saveDoc,...
            'OutputTopNode',true,...
            'ReverseTraverse',false,...
            'Output',mFileName);
            edit(mFileName);
        else
            errordlg(...
            sprintf(getString(message('rptgen:RptgenML_Root:fileNotWritableLabel')),mFileName),...
            getString(message('rptgen:RptgenML_Root:sprintf_GenerateMATLABFile')));
            mFileName='';
        end
    end


    function defaultFileName=locGetDefaultMFile(saveDoc)

        rptName=saveDoc.RptFileName;
        [~,mFile]=fileparts(rptName);
        if isempty(mFile)
            mFile=getString(message('rptgen:RptgenML_Root:reportLabel'));
        end



        mFileN=double(mFile);
        mFile(~(...
        (mFileN>=double('a')&mFileN<=double('z'))|...
        (mFileN>=double('A')&mFileN<=double('Z'))|...
        (mFileN>=double('0')&mFileN<=double('9'))))='_';
        defaultFileName=['build',mFile,'.m'];




