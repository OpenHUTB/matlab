
function vmap_cEmitted=insertIseXSGCompileScripts(this,fid,vmap_cEmitted)


    xsgCodeGenPath=targetcodegen.xilinxsysgendriver.getXSGCodeGenPath();
    if(~isempty(xsgCodeGenPath))
        if(~vmap_cEmitted)
            fprintf(fid,'vmap -c\n');
            vmap_cEmitted=true;
        end

        target=hdlsynthtoolenum.ISE;
        mapXilinxStr=hdlprinttargetcodegenheaders(target,this.getDUTLanguage,true);
        fprintf(fid,['\nset curDir [pwd]\n',mapXilinxStr,'\n']);
        for i=1:length(xsgCodeGenPath)
            libName=xsgCodeGenPath{i};
            vcomStr=vcom(this,libName,target);
            fprintf(fid,...
            ['cd ',libName,'\n',...
            mapXilinxStr,'\n',...
            vcomStr,...
            'cd ','$curDir\n',...
            'vmap ',libName,' ',libName,'/',libName,'\n',...
            ]);
        end
    end
end

function tclStr=vcom(this,libName,target)


    tclStr='';

    fileList=targetcodegen.xilinxisesysgendriver.getXSGHDLFiles(fullfile(this.codegendir,libName));

    lang=this.getDUTLanguage;
    tclStr=sprintf('%svlib %s\n',tclStr,libName);
    flags=['-work ',libName,' -nowarn 1 ',this.SimulatorFlags];
    if(strcmpi(lang,'vhdl'))
        compCmd=this.HdlCompileVHDLCmd;
    else
        compCmd=this.HdlCompileVerilogCmd;
        [pathToXilinx,~]=targetcodegen.xilinxdriver.getPathToXilinx('verilog',target);

        pathWithinXilinx='/verilog/src/glbl.v';

        tclStr=[tclStr,sprintf(compCmd,flags,[pathToXilinx,pathWithinXilinx])];
    end
    for i=1:length(fileList)
        tclStr=[tclStr,sprintf(compCmd,flags,fileList{i})];%#ok<*AGROW>
    end
end

