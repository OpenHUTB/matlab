function sigtype=hdlissignaltype(signal,varargin)
























    narginchk(1,2);

    if(nargin>1)
        switch lower(varargin{1})
        case{'scalar','vector','row_vector','column_vector','unordered_vector','matrix'}
            stype_check=lower(varargin{1});
        otherwise
            stype_check='all';
        end
    else
        stype_check='all';
    end


    for i=1:max(size(signal))
        sigtype(i)=hdlsignaltype(signal(i),stype_check);
    end



    function sigtype=hdlsignaltype(signal,stype_check)




        scalar_sig=~signal.Type.isArrayType;


        vector_sig=(~scalar_sig&&signal.Type.NumberOfDimensions==1);
        rowvec_sig=(vector_sig&&(signal.Type.isRowVector==1));
        colvec_sig=(vector_sig&&(signal.Type.isColumnVector==1));
        unordvec_sig=(vector_sig&&~rowvec_sig&&~colvec_sig);


        matrix_sig=(~scalar_sig&&~vector_sig);


        switch(stype_check)
        case 'scalar'
            sigtype=scalar_sig;
        case 'vector'
            sigtype=vector_sig;
        case 'row_vector'
            sigtype=rowvec_sig;
        case 'column_vector'
            sigtype=colvec_sig;
        case 'unordered_vector'
            sigtype=unordvec_sig;
        case 'matrix'
            sigtype=matrix_sig;
        otherwise
            sigtype.isscalar=scalar_sig;
            sigtype.isvector=vector_sig;
            sigtype.isrowvec=rowvec_sig;
            sigtype.iscolvec=colvec_sig;
            sigtype.isunordvec=unordvec_sig;
            sigtype.ismatrix=matrix_sig;
        end





