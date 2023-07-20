function qout=divide(q,r)%#codegen





    qout=Aero.internal.shared.quaternion.multiply(...
    Aero.internal.shared.quaternion.inv(r),q);

end