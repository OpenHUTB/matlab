function qinv=inv(q)%#codegen





    qinv=Aero.internal.shared.quaternion.conj(q)./...
    (Aero.internal.shared.quaternion.norm(q)*ones(1,4));

end