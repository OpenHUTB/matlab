function build(this,fullBuild,messageClient)







    if nargin<2
        fullBuild=true;
    end

    oldSafe=this.Safe;






    prevDir=pwd;
    try
        r=this.up;
        if nargin>2
            try
                rptgen.internal.gui.GenerationDisplayClient.setMessageClient(messageClient);
            catch
            end
        elseif~isempty(r)&&isa(r,'RptgenML.Root')
            try
                r.getDisplayClient;
            catch
            end
        end
        try
            rptgen.internal.gui.GenerationDisplayClient.staticClearMessages();
        catch
        end

        rptgen.displayMessage(sprintf(getString(message('rptgen:RptgenML_ComponentMaker:buildingMsg')),this.DisplayName),2);


        this.makePackageDir;
        this.makeClassDir;
        cd(this.ClassDir);

        this.makeSchema;
        this.makeConstructor;


        if fullBuild
            this.makeName;
            this.makeDescription;
            this.makeType;
            this.makeParentable;
            this.makev1oldname;


            this.makeDialogSchema;
            this.makeOutline;
            this.makeExecute;



            if(this.isWriteHeader)
                this.makeContentType;
            end

            RptgenML.writeHtmlHelp(this);
            this.makeViewHelp;

            this.makeRegistry;
            this.makeLibraryComponent;

            this.makeQe_Test;
        end

        this.setDirty(false);


        this.clearClasses;
        rehash;


    catch ME
        errMsg=ME.message;
        crIdx=strfind(errMsg,newline);
        if~isempty(crIdx)
            errMsg=errMsg(crIdx(1)+1:end);
        end

        rptgen.displayMessage(errMsg,1);
        rptgen.displayMessage(getString(message('rptgen:RptgenML_ComponentMaker:buildIncompleteMsg')),2);

    end

    try
        com.mathworks.toolbox.rptgencore.GenerationDisplayClient.reset;
    catch
    end

    cd(prevDir);



    this.Safe=oldSafe;












