using DataFrames, DataFramesMeta, StatsPlots, StatsBase, CSV


function main()
    df_c = CSV.read(joinpath(homedir(), "Desktop", "c.csv"), DataFrame)
    df_bf = CSV.read(joinpath(homedir(), "Desktop", "bf.csv"), DataFrame)
    
    df_c_int8 = @where(df_c, :int_type .== "Int8")
    df_c_int128 = @where(df_c, :int_type .== "Int128")
    df_bf_int8 = @where(df_bf, :int_type .== "Int8")

    df_c_int_types = [first(i.int_type) for i in groupby(df_c, :int_type)]
    df_c_runtime_avgs = [mean(i.run_time_ms) for i in groupby(df_c, :int_type)]
    df_bf_int_types = [first(i.int_type) for i in groupby(df_bf, :int_type)]
    df_bf_runtime_avgs = [mean(i.run_time_ms) for i in groupby(df_bf, :int_type)]

    println(df_bf_int_types)
    println(df_bf_runtime_avgs)

    plt = bar(
        # df_c.int_type, 
        # df_c.run_time_ms, 
        # categories,
        # unique(df_c.int_type),
        df_c_int_types,
        # Int[get(frequencies, c, 0) for c in categories],
        # df_c.run_time_ms,
        df_c_runtime_avgs,
        yaxis=:log,
        # legend = false,
        label = "Clever",
        xticks = (0.5:length(df_c_int_types), df_c_int_types),
        xrotation = 45,
        fontfamily = font("Times"),
        xlabel = "Int type",
        ylabel = "Run time in ms",
        title = "Run time analysis on varying integer types"
    )
    bar!(
        # df_bf.int_type,
        df_bf_int_types,
        # [first(i.int_type) for i in groupby(df_bf, :int_type)],
        df_bf_runtime_avgs,
        # df_c.run_time_ms,
        # [mean(i.run_time_ms) for i in groupby(df_bf, :int_type)],
        label = "Brute force"
    )
    
    savefig(plt, joinpath(homedir(), "Desktop", "test.pdf"))

    return nothing
end

main()
