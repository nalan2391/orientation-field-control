function robot = makeFrankaPanda()
       
    % degrees of freedom
    robot.dof = 7;
    
    % screws A_i, i-th screw described in i-th frame
    robot.A = [0 0 0 0 0 0 0
               0 0 0 0 0 0 0
               1 1 1 1 1 1 1
               0 0 0 0 0 0 0
               0 0 0 0 0 0 0
               0 0 0 0 0 0 0];
     
    % link frames M_{i,i-1}
    robot.M(:,:,1) = [1 0 0 0
                      0 1 0 0
                      0 0 1 0.333
                      0 0 0 1];

    robot.M(:,:,2) = [1 0 0 0
                      0 0 1 0
                      0 -1 0 0
                      0 0 0 1];

    robot.M(:,:,3) = [1 0 0 0
                      0 0 -1 -0.316
                      0 1 0 0
                      0 0 0 1];

    robot.M(:,:,4) = [1 0 0 0.0825
                      0 0 -1 0
                      0 1 0  0
                      0 0 0 1];

    robot.M(:,:,5) = [1 0 0 -0.0825
                      0 0 1 0.384
                      0 -1 0 0
                      0 0 0 1];

    robot.M(:,:,6) = [1 0 0 0
                      0 0 -1 0
                      0 1 0 0
                      0 0 0 1];

    robot.M(:,:,7) = [1 0 0 0.088
                      0 0 -1 0
                      0 1 0 0
                      0 0 0 1];
    
    for i = 1:robot.dof
        robot.M(:,:,i) = inverse_SE3(robot.M(:,:,i));
    end
    
    % end-effector frame M_{n,b}
    robot.M_ee = [1  0  0  0
                  0  1  0  0
                  0  0  1  0.11
                  0  0  0  1];
              
    % M_{s,b}
    robot.M_sb = eye(4,4);
    for i = 1:robot.dof
        robot.M_sb = robot.M_sb*inverse_SE3(robot.M(:,:,i));
    end
    robot.M_sb = robot.M_sb * robot.M_ee;
    
        
    % spatial screws A_s & body screws A_b
    M_si = eye(4,4);
    for i = 1:robot.dof
        M_si = M_si*inverse_SE3(robot.M(:,:,i));
        robot.A_s(:,i) = large_Ad(M_si)*robot.A(:,i);
        robot.A_b(:,i) = large_Ad(inverse_SE3(robot.M_sb))*robot.A_s(:,i);
    end
    
    % joint limits
    robot.q_min = [-2.8973 -1.7628  -2.8973  -3.0718  -2.8973  -0.0175  -2.8973]';
    robot.q_max = [ 2.8973  1.7628   2.8973  -0.0698   2.8973   3.752    2.8973]';
    robot.qdot_min = [-2.1750 -2.1750 -2.1750 -2.1750 -2.6100 -2.6100 -2.6100]';
    robot.qdot_max = [2.1750   2.1750  2.1750  2.1750  2.6100  2.6100  2.6100]';
    
    % inertia matrix Phi for linear dynamics tau = Y * Phi
    robot.Phi = [2.35999957910000;-0.00134911186423401;-0.0908345874005549;-0.155919559200638;0.0324837788664708;0.0246809930696007;0.0125650453571640;-5.19262887290950e-05;-0.00600122514982288;-8.91326121608616e-05;
                 2.37951883300000;-0.00239627572003166;-0.156965528454061;0.0919609174472767;0.0329471421649429;0.0126993257209242;0.0250542187452413;-0.000158070900511509;0.00606622389537189;9.26085184175320e-05;
                 2.64988233370000;0.116853758178617;0.0995424472814311;-0.0788786327046917;0.0190172833751530;0.0225251638385154;0.0231657412841902;-0.00438959455489880;0.00296306444923341;0.00347836753138544;
                 2.69480187440000;-0.104766654655906;0.0835933258907134;0.100122869823070;0.0197005163775299;0.0223073435476337;0.0221836838597793;0.00324988385540623;-0.00310583266463583;0.00389250810071051;
                 2.98128168640000;-0.00155566530895208;0.179878105638478;-0.341973015761897;0.0826362651086839;0.0662934587315345;0.0223562441034096;9.38623579443453e-05;0.0206332258153731;-0.000178445250459010;
                 1.12858063090000;0.0665983116416480;0.0220799372899408;0.0107404582086963;0.00313945056354661;0.00802194924825995;0.00906685026789732;-0.00130295213687202;-0.000210129996227321;-0.000633801753611908;
                 0.405291246500000;0.00713995105121771;0.00771384769740003;0.0342095480572609;0.00366601199000215;0.00364528355553770;0.00133337198530857;-0.000135893620826041;-0.000651105213323667;-0.000602664135291465];

    robot.G = zeros(6,6,robot.dof);
    for i = 1:robot.dof
        robot.G(:,:,i) = convertInertiaPhiToG(robot.Phi(10*(i-1)+1:10*i));
    end
    
end