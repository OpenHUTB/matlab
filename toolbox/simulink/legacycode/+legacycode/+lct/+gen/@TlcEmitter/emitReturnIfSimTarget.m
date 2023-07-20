function emitReturnIfSimTarget(this,codeWriter,methKind,assertNeverCalled)







    assert(this.LctSpecInfo.Specs.Options.stubSimBehavior);

    codeWriter.wBlockStart('%if IsModelReferenceSimTarget()');
    codeWriter.wComment('This TLC file does not inline the call to the legacy code for the model reference SIM target.');
    codeWriter.wComment('It can be used to generate stub behavior in a SIM target build used to support diagram update in model block SIL/PIL.');





    if strcmp(methKind,'BlockTypeSetup')
        if numel(this.LctSpecInfo.DWorks.Items)>0
            DWorkTypeNames=unique({this.LctSpecInfo.DWorks.Items.DataTypeName});
            codeWriter.wLine('%openfile typeDefBuffer');
            for kDWork=1:numel(DWorkTypeNames)
                codeWriter.wLine('typedef int_T %s;',DWorkTypeNames{kDWork});
            end
            codeWriter.wLine('%closefile typeDefBuffer');
            codeWriter.wLine('%<LibCacheTypedefs(typeDefBuffer)>');
        end
    end

    if assertNeverCalled

        codeWriter.wLine('%%<LibSetRTModelErrorStatus("\\"This function (%s) should never be called.\\"")>',methKind);
        codeWriter.wLine('return;');
    end

    codeWriter.wLine('%return');
    codeWriter.wBlockEnd();