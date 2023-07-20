function[fcn,success,err_id,err_msg]=parseOperationPrototype(fcn_str,maxShortNameLength)





















    success=true;
    err_id='';
    err_msg='';
    fcn.name='UNDEFINED';




    output=regexp(fcn_str,'^(?<name>\w+)\s*\((?<arg_str>[\s\w,\[\]]*)\)\s*$|^(?<name>\w+)\s*$','names');



    if nargin<2
        maxShortNameLength=255;
    end

    if isempty(output)
        success=false;
        err_id='RTW:autosar:parseOperationPrototypeFcnExtractionError';
        err_msg=DAStudio.message(err_id,fcn_str);
        return;
    end

    fcn.name=output.name;
    arg_str=output.arg_str;


    [isvalid,msg]=autosarcore.checkIdentifier(fcn.name,'shortName',maxShortNameLength);
    if~isvalid
        success=false;
        err_id='RTW:autosar:parseOperationPrototypeFcnInvalidShortName';
        err_msg=DAStudio.message(err_id,msg);
        return;
    end

    if~isempty(arg_str)




        arg_str(end+1)=',';
        arg_str=regexp(arg_str,'\s*(?<arg_str>[^,]*),','names');

        for ii=1:length(arg_str)
            argInfo=regexp(arg_str(ii).arg_str,'^\s*(?<dir>(IN|INOUT|OUT))\s+(?<dt>\w+)\s+(?<name>\w+)(?<dims>(\[\d+\]){1,})?\s*$','names');

            if isempty(argInfo)
                success=false;
                err_id='RTW:autosar:parseOperationPrototypeArgExtractionError';
                err_msg=DAStudio.message(err_id,arg_str(ii).arg_str);
                return;
            end

            fcn.args(ii)=argInfo;


            [isvalid,msg]=autosarcore.checkIdentifier(fcn.args(ii).name,'shortName',maxShortNameLength);
            if~isvalid
                success=false;
                err_id='RTW:autosar:parseOperationPrototypeArgInvalidShortName';
                err_msg=DAStudio.message(err_id,msg);
                return;
            end


            if strcmp(fcn.args(ii).dir,'INOUT')
                success=false;
                err_id='RTW:autosar:parseOperationPrototypeINOUTNotSupported';
                err_msg=DAStudio.message(err_id);
                return;
            end


            o=regexp(fcn.args(ii).dims,'\[(?<width>\d+)\]','names');
            if isempty(o)
                fcn.args(ii).dims=1;
            else
                fcn.args(ii).dims=zeros(1,length(o));
                for jj=1:length(o)
                    fcn.args(ii).dims(jj)=str2double(o(jj).width);
                end
            end
        end


        uNames=unique({fcn.args.name});


        if numel(uNames)~=numel({fcn.args.name})
            success=false;
            err_id='RTW:autosar:parseOperationPrototypeDuplicateArgs';
            err_msg=DAStudio.message(err_id);
            return;
        end


        dupNames=intersect(uNames,unique({fcn.args.dt}));
        if~isempty(dupNames)
            success=false;
            err_id='RTW:autosar:parseOperationPrototypeInvalidTypenameAsArgname';
            err_msg=DAStudio.message(err_id,dupNames{1});
            return
        end

    else
        fcn.args=[];
    end



