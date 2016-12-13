class LsReports::SpreadsheetController < LsReports::BaseController
    layout 'full_width'
    include LsReports::SpreadsheetHelper

    ##
    # show lime_survey
    def show
        load_data
        cols = show_params[:cols].is_a?(Array) ? show_params[:cols] : []
        cols.map{|v|v.to_i}
        if @fm.not_found?
            # Throw redirect on not found
            flash[:error] = 'Nothing left to show after filtering'
            redirect_to ls_reports_path
        end

        @lime_survey.wipe_response_sets

        #@response_sets = hf_get_response_sets @lime_survey, cols
        @response_sets = hf_flatten_response_sets @lime_survey
 
        @rs_data = hf_transpose_response_sets @response_sets
        @rs_data.sort_by!{|obj| obj["StartDt"]}
        @rs_questions = hf_transpose_questions @response_sets

        if hf_found_competency(@response_sets)
            render :show_epa
        else
        #binding.pry
            render :show
        end
    end


    def will_view_raw_data?
        true
    end

    private

    def show_params
        params.permit(:cols=>[])
    end

end
