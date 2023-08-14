



function[isOK,errMsg]=dialogControl(hObj,hDlg,action)


    isOK=true;
    errMsg='';

    switch lower(action)
    case 'preapply'

        if strcmpi(hObj.PSAnnotationType,'Check')
            annotationType='RTE';
        elseif strcmpi(hObj.PSAnnotationType,'Defect')
            annotationType='defect';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-C')
            annotationType='MISRA-C';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-AC-AGC')
            annotationType='MISRA-AC-AGC';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-C-2012')
            annotationType='MISRA-C3';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-C++')
            annotationType='MISRA-CPP';
        elseif strcmpi(hObj.PSAnnotationType,'JSF')
            annotationType='JSF';
        elseif strcmpi(hObj.PSAnnotationType,'ISO-17961')
            annotationType='iso-17961';
        elseif strcmpi(hObj.PSAnnotationType,'CERT-C')
            annotationType='cert-c';
        elseif strcmpi(hObj.PSAnnotationType,'CERT-CPP')
            annotationType='cert-cpp';
        elseif strcmpi(hObj.PSAnnotationType,'AUTOSAR-CPP14')
            annotationType='autosar-cpp14';
        elseif strcmpi(hObj.PSAnnotationType,'GUIDELINES')
            annotationType='guideline';
        else
            annotationType='custom';
        end

        if hObj.PSOnlyOneCheck

            checkIdx=hDlg.getWidgetValue('_pslink_PSAnnotationKind_combo_tag')+1;

            if strcmpi(hObj.PSAnnotationType,'misra-c')

                checkList=pslinkprivate('getAnnotationValues','misra');
                checksStr=pslinkprivate('annotationHelper',...
                'extractMisraRuleNumber',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'misra-ac-agc')

                checkList=pslinkprivate('getAnnotationValues','misraagc');
                checksStr=pslinkprivate('annotationHelper',...
                'extractMisraRuleNumber',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'misra-c-2012')

                checkList=pslinkprivate('getAnnotationValues','misrac2012');
                checksStr=pslinkprivate('annotationHelper',...
                'extractmisrac2012rulenumber',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'misra-c++')

                checkList=pslinkprivate('getAnnotationValues','misracxx');
                checksStr=pslinkprivate('annotationHelper',...
                'extractMisraCxxRuleNumber',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'jsf')

                checkList=pslinkprivate('getAnnotationValues','jsf');
                checksStr=pslinkprivate('annotationHelper',...
                'extractJsfRuleNumber',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'defect')

                checkList=pslinkprivate('getAnnotationValues','defect');
                checksStr=pslinkprivate('annotationHelper',...
                'extractDefectCode',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'iso-17961')

                checkList=pslinkprivate('getAnnotationValues','iso-17961');
                checksStr=pslinkprivate('annotationHelper',...
                'extractIsoCode',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'cert-c')

                checkList=pslinkprivate('getAnnotationValues','certc');
                checksStr=pslinkprivate('annotationHelper',...
                'extractCertCCode',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'cert-cpp')

                checkList=pslinkprivate('getAnnotationValues','certcpp');
                checksStr=pslinkprivate('annotationHelper',...
                'extractCertCppCode',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'autosar-cpp14')

                checkList=pslinkprivate('getAnnotationValues','autosar');
                checksStr=pslinkprivate('annotationHelper',...
                'extractAutosarCode',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'guidelines')

                checkList=pslinkprivate('getAnnotationValues','guidelines');
                checksStr=pslinkprivate('annotationHelper',...
                'extractGuidelinesCode',checkList{checkIdx});
            elseif strcmpi(hObj.PSAnnotationType,'custom')

                checkList=pslinkprivate('getAnnotationValues','custom');
                checksStr=pslinkprivate('annotationHelper',...
                'extractCustomCode',checkList{checkIdx});
            else

                checkList=pslinkprivate('getAnnotationValues','checks');
                checksStr=pslinkprivate('annotationHelper',...
                'extractCheckCode',checkList{checkIdx});
            end

        else

            checksStr=hDlg.getWidgetValue('_pslink_PSAnnotationKind_edit_tag');
        end


        try
            pslinkprivate('annotationHelper',...
            'checkAnnotation',annotationType,checksStr);
        catch Me
            isOK=false;
            errMsg=Me.message;
            return
        end


        hObj.PSAnnotationKind=checksStr;

    case 'postapply'

        if strcmpi(hObj.PSAnnotationType,'Check')
            annotationType='RTE';
        elseif strcmpi(hObj.PSAnnotationType,'Defect')
            annotationType='DEFECT';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-C')
            annotationType='MISRA-C';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-C++')
            annotationType='MISRA-CPP';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-AC-AGC')
            annotationType='MISRA-AC-AGC';
        elseif strcmpi(hObj.PSAnnotationType,'MISRA-C-2012')
            annotationType='MISRA-C3';
        elseif strcmpi(hObj.PSAnnotationType,'JSF')
            annotationType='JSF';
        elseif strcmpi(hObj.PSAnnotationType,'ISO-17961')
            annotationType='ISO-17961';
        elseif strcmpi(hObj.PSAnnotationType,'CERT-C')
            annotationType='CERT-C';
        elseif strcmpi(hObj.PSAnnotationType,'CERT-CPP')
            annotationType='CERT-CPP';
        elseif strcmpi(hObj.PSAnnotationType,'AUTOSAR-CPP14')
            annotationType='AUTOSAR-CPP14';
        elseif strcmpi(hObj.PSAnnotationType,'GUIDELINES')
            annotationType='GUIDELINE';
        else
            annotationType='CUSTOM';
        end

        pslinkprivate('blockAnnotation',hObj.Block.Handle(),...
        annotationType,...
        hObj.PSAnnotationKind,...
        hObj.PSClassification,...
        hObj.PSStatus,...
        hObj.PSComment...
        );


        customContext=pslink.toolstrip.PslinkContextManager.getContext(bdroot(hObj.Block.Handle()));
        customContext.toggleRefreshAnnotations();

    case 'help'
        helpview('bugfinder','simulink_block_add_polyspace_annotation_toolstrip');

    otherwise

    end

