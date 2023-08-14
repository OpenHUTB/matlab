function[valid,msg,s]=xmlvalidate(xmlfile,varargin)


















    if nargin<2
        dependencies.error('SchemaFileMissing');
    end

    numSchemaFiles=length(varargin);

    for i=1:numSchemaFiles
        if~exist(varargin{i},'file')
            dependencies.error('SchemaFileNotFound',varargin{i});
        end
    end

    valid=true;
    msg='';
    s=struct('LineNumber',{},'ColumnNumber',{},'Message',{});

    d=dir(xmlfile);
    if isempty(d)
        dependencies.error('XMLFileNotFound',xmlfile);
    elseif d(1).bytes==0

        valid=false;
        msg=dependencies.message('XMLFileEmpty');
        return;
    end



    sx=java.io.FileInputStream(xmlfile);
    ss=java.util.Vector(numSchemaFiles);
    for i=1:numSchemaFiles
        ss.add(java.io.FileInputStream(varargin{i}));
    end
    import com.mathworks.xml.XMLValidator;
    try
        results=XMLValidator.validate(sx,ss);
    catch E
        valid=false;
        msg=E.message;
        sx.close();
        itr=ss.iterator();
        while itr.hasNext()
            itr.next().close();
        end
        return;
    end
    sx.close();
    itr=ss.iterator();
    while itr.hasNext()
        itr.next().close();
    end


    if results.hasErrors()
        valid=false;
        msg=char(results.getSimpleStringMessage());
        vec=results.getErrors;
        for i=1:vec.size()
            spe=vec.elementAt(i-1);
            s(i).LineNumber=double(spe.getLineNumber());
            s(i).ColumnNumber=double(spe.getColumnNumber());
            s(i).Message=char(spe.getMessage());
        end
    end

