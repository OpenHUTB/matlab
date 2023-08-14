function o=db_output(varargin)















    o=rpt_xml.db_output;


    if(nargin>0)
        srcName=varargin{1};
        if rptgen.use_java
            srcExt=char(getExtension(...
            com.mathworks.toolbox.rptgencore.output.OutputFormat.getFormat('db')));
            o.SrcFileName=rptgen.findFile(srcName,srcExt,true);
        else
            srcExt=char(getExtension(...
            rptgen.internal.output.OutputFormat.getFormat('db')));
            o.SrcFileName=rptgen.findFile(srcName,srcExt,true);
        end
    end


    if(nargin>1)
        format=varargin{2};
        o.Format=format;
    end


    if(nargin>2)
        stylesheet=varargin{3};
        try
            o.setStylesheet(stylesheet);
        catch ME
            error(message('rptgen:rx_db_output:invalidStylesheet',...
            stylesheet));
        end
    end


    dstExt=char(o.getFormat.getExtension);
    if(nargin>3)
        distName=varargin{4};
        o.DstFileName=rptgen.findFile(distName,dstExt,true);
    else
        [inPath,inFile]=fileparts(o.SrcFileName);
        o.DstFileName=fullfile(inPath,[inFile,'.',dstExt]);
    end

