function[n_vector_used,trq_vector_used,cf_vector_used,cf_vector_flipped,IsNotPassiveBraking,IsNotPassiveMotoring,through_one]=torque_converter_vector_private(n_vector,cf_vector_corrected,trq_vector,cf_vector_reference_speed,peak_cf)%#codegen



    coder.allowpcode('plain');

    through_one=any(n_vector==1);

    if n_vector(end)<1||through_one
        n_vector_used=[n_vector(:);1];
        cf_vector_used=[cf_vector_corrected(:);peak_cf];
        trq_vector_used=[trq_vector(:);0];
    else
        n_vector_used=[n_vector(:)-1;0].*([n_vector(:);0]<1)+[0;n_vector(:)-1].*([0;n_vector(:)]>1)+1;
        trq_vector_used=[trq_vector(:);0].*([n_vector(:);0]<1)+[0;trq_vector(:)].*([0;n_vector(:)]>1);
        if cf_vector_reference_speed==1
            cf_vector_used=[cf_vector_corrected(:)-peak_cf;0].*([n_vector(:);0]<1)+[0;cf_vector_corrected(:)-peak_cf].*([0;n_vector(:)]>1)+peak_cf;
        else
            cf_vector_used=[cf_vector_corrected(:)-peak_cf;0].*([n_vector(:);0]<1)+[0;cf_vector_corrected(:)./(n_vector(:)+(n_vector(:)==0))-peak_cf].*([0;n_vector(:)]>1)+peak_cf;
        end
    end

    cf_vector_flipped=cf_vector_corrected(:).*(n_vector(:)<1)+cf_vector_corrected(:)./(n_vector(:)+(n_vector(:)==0)).*(n_vector(:)>1);

    IsNotPassiveMotoring=any(n_vector(:).*trq_vector(:).*(n_vector(:)<1)>=1);
    IsNotPassiveBraking=any(2+(n_vector(:).*trq_vector(:)-2).*(n_vector(:)>1)<=1);

end