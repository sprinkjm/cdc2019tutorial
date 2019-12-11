function result = b_data_plotter


    % Original controller's performance on
    % exemplar input signal
    filename='cmdTest__2016-07-14-16-35-11';
    matfile = loadit(filename);
    plotit(matfile,'Original Controller Performance');

    
    % After doing controller tuning
    filename='cmdTest__2016-07-15-16-45-45';
    matfile = loadit(filename);
    plotit(matfile,'Newly tuned controller');
    

    % Tuned controller, checking for windup
    filename='cmdTest__2016-07-15-16-50-38';
    matfile = loadit(filename);
    plotit(matfile,'Tuned controller, check for windup');

    result = 'Success';

    
end

function matfile = loadit(filename)
    if( exist( [filename '.mat'] ) == 2 )
        disp(['Reusing existing MAT file, if you get errors, consider deleting ' filename '.mat']);
        matfile = filename;
    else
        path_prefix='';
        bagfile=rosbag([path_prefix filename '.bag']);

        cmd_vel_wrench_bag = select(bagfile,'Topic','/catvehicle/cmd_vel_wrench');
        cmd_vel_bag = select(bagfile,'Topic','/catvehicle/cmd_wrench');
        vel_bag = select(bagfile,'Topic','/catvehicle/vel');
        accel_bag = select(bagfile,'Topic','/catvehicle/accelerator');
        brake_bag = select(bagfile,'Topic','/catvehicle/brake');
        steering_bag = select(bagfile,'Topic','/catvehicle/steering');

        cmd_vel_wrench = timeseries(cmd_vel_wrench_bag,'Linear.X');
        cmd_wrench = timeseries(cmd_vel_bag,'Force.X');
        cmd_angle = timeseries(cmd_vel_bag,'Torque.Z');
        vel = timeseries(vel_bag,'Linear.X');
        steering = timeseries(steering_bag,'Torque.Z');

        clear bagfile cmd_vel_bag cmd_vel_wrench_bag vel_bag accel_bag brake_bag steering_bag
        matfile = [path_prefix filename];
        save(matfile);
    end
end

function plotit(matfile,subtitle)
    load(matfile);
%%
Time1 = min(cmd_wrench.Time(1),min(cmd_angle.Time(1),min(vel.Time(1),steering.Time(1))));

figure
hold on
plot(cmd_wrench.Time-Time1,cmd_wrench.Data);
legend({'u'});
title(['Accelerator and brake commands (' subtitle ')']); 
xlabel 'Time (s)'
ylabel '% angle'

figure
hold on
plot(vel.Time-Time1,vel.Data);
plot(cmd_vel_wrench.Time-Time1,cmd_vel_wrench.Data);
legend({'v','r'});
xlabel 'Time (s)'
ylabel 'Velocity (m/s)'

title(['Velocity and reference velocity (' subtitle ')']); 

end


% an inaccurate (but useful for visualization) conversion of
% steering percentage to tire angle in rads
% It is inaccurate because steering angles do not match due to the
% rack and pinion angles of individual front tires and the translation
% is nonlinear in the physical system
function angle = steering2angle(steering)
    max_angle = 0.4; 
    angle = steering*max_angle/100;
end