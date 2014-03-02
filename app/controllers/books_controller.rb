class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy,:destroy_comment]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end
  def new_many
    @book =[]
    @book << Book.new
    @next_action = :create_many
  end

  # GET /books/1/edit
  def edit
  end
  def edit_many
    @book = []
    @book = Book.all
    @next_action = :update_many
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)
    if params[:commit] == "追加" then
      @book.comments.build

      render :action => :new
      return
    end

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render action: 'show', status: :created, location: @book }
      else
        format.html { render action: 'new' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end
  def create_many
    @book = []
    params[:book].each{|book|
      @book << Book.new(book[1])
    }
    @book.each{|book|book.valid?}
    if params[:commit] =="追加" then
      @book << Book.new
      @next_action = :create_many
      render new_many_books_path
      return
    end
    @isError = false
    @book.each{|book|@isError = true if book.errors.any?}
    if @isError == false then
      @book.each{|book|book.save}
      redirect_to :action => :index
    else
      render new_many_books_path
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    if params[:commit] == "追加" then
      @book.update_attributes(book_params)
      @book.comments.new
      render :action => :edit
      return
    end
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end
  def update_many
    @book =[]
    params[:book].each{|book|
      obj=""
      if book[1]["id"].present? then
        obj = Book.find(book[1][:id])
        obj.valid?(book[1])
      else
        obj= Book.new(book[1])
        obj.valid?
      end
      @book << obj
    }
    @isError = false
    @book.each{|book| @isError = true if book.errors.any?}
    if params[:commit] == "追加" then
      obj = Book.new()
      @book << obj
      @next_action = :update_many
      render edit_many_books_path
      return
    end
    if @isError == false then
      @book.each{|book|book.save}
      redirect_to books_path
    else
      render edit_may_books_path
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url }
      format.json { head :no_content }
    end
  end
  def destroy_comment
    comment = Comment.find(params[:comment_id].to_i)
    comment.destroy
    respond_to do |format|
      format.html{ redirect_to edit_book_path(params[:id])}
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:title,:id,:comments_attributes =>[:content,:id])
    end
end
