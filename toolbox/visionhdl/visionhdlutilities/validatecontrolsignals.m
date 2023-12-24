function valid=validatecontrolsignals(Ctrl)

%#codegen
    coder.allowpcode('plain');

    coder.internal.errorIf(~isstruct(Ctrl),'visionhdl:controlsignals:FieldNameOrOrder');
    actualField=fieldnames(Ctrl);
    coder.internal.errorIf(numel(actualField)~=5,'visionhdl:controlsignals:FieldNameOrOrder');
    expectedField={'hStart';'hEnd';'vStart';'vEnd';'valid'};%#ok<EMCA>
    for ii=1:5
        coder.internal.errorIf(~strcmp(actualField{ii},expectedField{ii}),'visionhdl:controlsignals:FieldNameOrOrder');%#ok<EMCA>
    end

    validateattributes(Ctrl.hStart,{'logical'},{'scalar'},'','hStart');%#ok<EMCA>
    validateattributes(Ctrl.hEnd,{'logical'},{'scalar'},'','hEnd');%#ok<EMCA>
    validateattributes(Ctrl.vStart,{'logical'},{'scalar'},'','vStart');%#ok<EMCA>
    validateattributes(Ctrl.vEnd,{'logical'},{'scalar'},'','vEnd');%#ok<EMCA>
    validateattributes(Ctrl.valid,{'logical'},{'scalar'},'','valid');%#ok<EMCA>

    valid=true;
end

