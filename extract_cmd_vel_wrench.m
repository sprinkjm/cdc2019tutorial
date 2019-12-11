function result = extract_cmd_vel_wrench(filenames)
% reads data from the joystick and the car's commanded velocities to see
% what the response is, and where (if any) we can eliminate delay

if( nargin == 0 )
    filenames={};
    bagfiles = dir('2016-03*.bag');
    for i=1:length(bagfiles)
        [path,name,extension] = fileparts(bagfiles(i).name);
        filenames{end+1} = name;
    end
    % first try: had to e-stop it

    for i=1:length(filenames)
        matfile = loadit(filenames{i});
        plot_default_vars(matfile);
    end
else
    matfile = loadit(filenames);
    plot_default_vars(matfile);
end


result = 'Success';

end

function matfile = loadit(filename)
%     path_prefix='../../../28th July 2016 Tucson Dragway Experiment/Bag Files/';
    path_prefix='./';
    if( exist( [filename '.mat'] ) == 2 )
        disp(['Reusing existing MAT file, if you get errors, consider deleting ' path_prefix filename '.mat']);
        matfile = filename;
    else
        bagfile=rosbag([path_prefix filename '.bag']);
        
        % an array of possible things to write to file
        
        cmd_vel_bag = select(bagfile,'Topic','/catvehicle/cmd_vel');
        cmd_vel_wrench_bag = select(bagfile,'Topic','/catvehicle/cmd_vel_wrench');
        cmd_wrench_bag = select(bagfile,'Topic','/catvehicle/cmd_wrench');
        vel_bag = select(bagfile,'Topic','/catvehicle/vel');
        accel_bag = select(bagfile,'Topic','/catvehicle/accelerator');
        brake_bag = select(bagfile,'Topic','/catvehicle/brake');
        steering_bag = select(bagfile,'Topic','/catvehicle/steering');

        cmd_vel = timeseries(cmd_vel_bag,'Linear.X');
        cmd_vel_steering = timeseries(cmd_vel_bag,'Angular.Z');
        cmd_vel_wrench = timeseries(cmd_vel_wrench_bag,'Linear.X');
        cmd_wrench = timeseries(cmd_wrench_bag,'Force.X');
        cmd_angle = timeseries(cmd_wrench_bag,'Torque.Z');
        vel = timeseries(vel_bag,'Linear.X');
        steering = timeseries(steering_bag,'Torque.Z');
        accel = timeseries(accel_bag,'Force.X');
        brake = timeseries(brake_bag,'Force.X');

        clear cmd_vel_bag cmd_vel_wrench_bag vel_bag accel_bag brake_bag steering_bag
        matfile = filename;
        save(filename);
    end
end




function angle = steering2angle(steering)
    max_angle = 0.4; % no idea if this is correct or not, but it is rads
    angle = steering*max_angle/100;
end