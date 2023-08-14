






















function out=getRHdrAnnotation(filepath)

    function_revision=0;
    function_name='getRHdrAnnotation';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    key='tzsvq27h';


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    sqf_sysinfo=GetSqf(fid,key,'SystemInfo');
    if isempty(sqf_sysinfo)
        disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
        fclose(fid);
        return;
    end
    annotation=GetSqf(fid,key,'Annotation');



    fclose(fid);


    annotation_count=size(annotation,2);
    if annotation_count>0
        for ii=1:annotation_count
            s_temp=rmfield(annotation(ii),'reference_no');
            s_temp=rmfield(s_temp,'type');
            if(sqf_sysinfo.version<3.0)

                annotation_new(ii)=s_temp;
            elseif(sqf_sysinfo.version==3.0)


                s_temp=rmfield(s_temp,'AnnotationInfo');

                annotationcategory_temp=annotation(ii).AnnotationInfo.annotationCategory;
                s_temp.annotationCategory=annotationcategory_temp;
                annotation_new(ii)=s_temp;













            else


                s_temp=rmfield(s_temp,'AnnotationInfo');

                annotationcategory_temp=annotation(ii).AnnotationInfo.annotationCategory;
                s_temp.annotationCategory=annotationcategory_temp;
                annotation_new(ii)=s_temp;













            end
        end
    else
        annotation_new=[];
    end


    out=annotation_new;

