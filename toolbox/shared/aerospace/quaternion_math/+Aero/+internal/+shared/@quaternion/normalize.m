function qout=normalize(q)%#codegen





    qout=q./(Aero.internal.shared.quaternion.mod(q)*ones(1,4));

end
