#include <iostream>
#include <fstream>
#include <sstream>
#include <ios>
#include <iomanip>
#include <list>
#include <cstring>
#include <cmath>

using namespace std;

string format_account_number(int acct_no) {
  ostringstream out;
  out << internal << setfill('0') << setw(8) << acct_no;
  return out.str();
}

class PP
{
public:
  int i;
  int j;
  PP(int i,int j);
  string print(string lang);
};

PP::PP(int i,int j)
{
  this->i = i;
  this->j = j;
}

string PP::print(string lang = "vhdl")
{
  string out = "";
  if (lang.compare("vhdl") == 0)
  {
    if (this->i>=0 && this->j>=0)
      out = "P("+to_string(this->i)+")("+to_string(this->j)+")";
    if (this->i>=0 && this->j<0)
      out = "S("+to_string(this->i)+")";
    if (this->i<0 && this->j>=0)
      out = "C("+to_string(this->j)+")";
  }
  else
  {
    if (this->i>=0 && this->j>=0)
      out = "P["+to_string(this->i)+"]["+to_string(this->j)+"]";
    if (this->i>=0 && this->j<0)
      out = "S["+to_string(this->i)+"]";
    if (this->i<0 && this->j>=0)
      out = "C["+to_string(this->j)+"]";
  }
  return out;
}

class ADD
{
public:
  string a;
  string b;
  string cin;
  string s;
  string cout;
  int type;
  ADD(string a,string b,string cin,string s,string cout,int type);
  string Print(int id,string lang);
  friend ostream &operator<<(ostream &out, const ADD &obj);
};

ADD::ADD(string a,string b,string cin,string s,string cout,int type)
{
  this->a = a;
  this->b = b;
  this->cin = cin;
  this->s = s;
  this->cout = cout;
  this->type = type;
}

string ADD::Print(int id,string lang = "vhdl")
{
  stringstream adder;
  if (lang.compare("vhdl") == 0)
  {
    if (this->type==0)
    {
      adder << "  HA_"<< format_account_number(id) <<" : ha port map ("<<this->a<<","<<this->b<<","<<this->s<<","<<this->cout<<");";
    }
    else if (this->type==1)
    {
      adder << "  FA_"<< format_account_number(id) <<" : fa port map ("<<this->a<<","<<this->b<<","<<this->cin<<","<<this->s<<","<<this->cout<<");";
    }
  }
  else
  {
    if (this->type==0)
    {
      adder << "  ha HA_"<< format_account_number(id) <<" ("<<this->a<<","<<this->b<<","<<this->s<<","<<this->cout<<");";
    }
    else if (this->type==1)
    {
      adder << "  fa FA_"<< format_account_number(id) <<" ("<<this->a<<","<<this->b<<","<<this->cin<<","<<this->s<<","<<this->cout<<");";
    }
  }
  return adder.str();
}

ostream &operator<<(ostream &out, const ADD &obj)
{
  stringstream adder;
  if (obj.type==0)
  {
    adder << "Half_Adder HA("<<obj.a<<","<<obj.b<<","<<obj.s<<","<<obj.cout<<","<<")";
  }
  else if (obj.type==1)
  {
    adder << "Full_Adder FA("<<obj.a<<","<<obj.b<<","<<obj.cin<<","<<obj.s<<","<<obj.cout<<","<<")";
  }
  out << adder.str();
  return out;
}

PP **PP_Matrix;
list<ADD> Adders;

void print_matrix(int N, int M)
{
#ifdef DEBUG
  int i,j;
  int value;
  for (i=0; i<N+M; i++)
  {
    cout << endl;
    for (j=0; j<N+M; j++)
    {
      string node = PP_Matrix[i][j].print();
      int length = 9-node.length();
      for (int i=0; i<length; i++)
      {
        node = node + " ";
      }
      cout << node << " - ";
    }
  }
  cout << endl;
  cin >> value;
#endif
}

void partial_product_generation_schema(int type, int N, int M)
{
  int i,j,k;
  int new_i;
  PP_Matrix = (PP**) malloc((N+M)*sizeof(PP*));
  for (i=0; i<N+M; i++)
  {
    PP_Matrix[i] = (PP*) malloc((N+M)*sizeof(PP));
    for (j=0; j<N+M; j++)
    {
      PP_Matrix[i][j].i = -1;
      PP_Matrix[i][j].j = -1;
    }
  }
  if (type==0)
  {
    for (i=0; i<N; i++)
    {
      for (j=0; j<M; j++)
      {
        PP_Matrix[i][i+j].i = i;
        PP_Matrix[i][i+j].j = j;
      }
    }
  }
  else if (type==1)
  {
    for (i=0; i<N; i++)
    {
      new_i = i - 1;
      for (j=0; j<M; j++)
      {
        if (i+j<M)
        {
          PP_Matrix[i][i+j].i = i;
          PP_Matrix[i][i+j].j = j;
        }
        else
        {
          PP_Matrix[new_i][j+i].i = i;
          PP_Matrix[new_i][j+i].j = j;
          new_i--;
        }
      }
    }
  }
}

void dadda_multiplier_reduction_schema(int N, int M)
{
  unsigned int weight;
  unsigned int local_weight;
  unsigned int dadda_hight;
  unsigned int desired_hight;
  unsigned int index = 0;
  int c_index;
  int c_nindex;
  int s_index;
  int c_array[N];
  int c_narray[N];
  int s_array[N];
  int restart;
  int num;
  int i,j,k,l;
  int prior;
  c_index = 0;
  for (j=0; j<N; j++)
  {
    c_array[j] = -1;
  }
  while (1)
  {
    weight = 0;
    for (j=0; j<N+M; j++)
    {
      local_weight = 0;
      for (i=0; i<N+M; i++)
      {
        if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
        {
          ++local_weight;
        }
        else
        {
          break;
        }
      }
      if (weight<local_weight)
      {
        weight = local_weight;
      }
    }
    if (weight<3)
    {
      break;
    }
    dadda_hight = 2;
    desired_hight = 0;
    while(dadda_hight<weight)
    {
      desired_hight = dadda_hight;
      dadda_hight = floor(((float)dadda_hight)*((float)1.5));
    }
    restart = 0;
    for (j=0; j<N+M; j++)
    {
      if (restart == 0)
      {
        c_nindex = c_index;
        for (i=0; i<N; i++)
        {
          c_narray[i] = c_array[i];
        }
        c_index = 0;
        s_index = 0;
        for (i=0; i<N; i++)
        {
          c_array[i] = -1;
        }
        for (i=0; i<N; i++)
        {
          s_array[i] = -1;
        }
      }
      local_weight = c_nindex+s_index;
      for (i=0; i<N+M; i++)
      {
        if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
        {
          ++local_weight;
        }
        else
        {
          break;
        }
      }
      print_matrix(N,M);
      if (desired_hight >= local_weight)
      {
        num = 0;
        if (c_nindex == 0)
        {
          continue;
        }
        restart = 0;
      }
      else if ((desired_hight+1) == local_weight)
      {
        string a = PP_Matrix[0][j].print();
        string b = PP_Matrix[1][j].print();
        string cin = "";
        string s = "S("+to_string(index)+")";
        string cout = "C("+to_string(index)+")";
        Adders.push_back(ADD(a,b,cin,s,cout,0));
        PP_Matrix[0][j].i = -1;
        PP_Matrix[0][j].j = -1;
        PP_Matrix[1][j].i = -1;
        PP_Matrix[1][j].j = -1;
        c_array[c_index] = index;
        s_array[s_index] = index;
        ++c_index;
        ++s_index;
        ++index;
        num = 2;
        restart = 0;
      }
      else
      {
        string a = PP_Matrix[0][j].print();
        string b = PP_Matrix[1][j].print();
        string cin = PP_Matrix[2][j].print();
        string s = "S("+to_string(index)+")";
        string cout = "C("+to_string(index)+")";
        Adders.push_back(ADD(a,b,cin,s,cout,1));
        PP_Matrix[0][j].i = -1;
        PP_Matrix[0][j].j = -1;
        PP_Matrix[1][j].i = -1;
        PP_Matrix[1][j].j = -1;
        PP_Matrix[2][j].i = -1;
        PP_Matrix[2][j].j = -1;
        c_array[c_index] = index;
        s_array[s_index] = index;
        ++c_index;
        ++s_index;
        ++index;
        num = 3;
        if (PP_Matrix[3][j].i>=0 || PP_Matrix[3][j].j>=0)
        {
          restart = 1;
        }
      }
      print_matrix(N,M);
      for (k=0; k<num; k++)
      {
        for (i=0; i<N+M-1; i++)
        {
          if (PP_Matrix[i][j].i<0 && PP_Matrix[i][j].j<0)
          {
            PP_Matrix[i][j].i = PP_Matrix[i+1][j].i;
            PP_Matrix[i][j].j = PP_Matrix[i+1][j].j;
            PP_Matrix[i+1][j].i = -1;
            PP_Matrix[i+1][j].j = -1;
          }
        }
      }
      print_matrix(N,M);
      if (restart == 0)
      {
        for (k=0; k<(c_nindex+s_index); k++)
        {
          for (i=N+M-1; i>0; i--)
          {
            PP_Matrix[i][j].i = PP_Matrix[i-1][j].i;
            PP_Matrix[i][j].j = PP_Matrix[i-1][j].j;
            PP_Matrix[i-1][j].i = -1;
            PP_Matrix[i-1][j].j = -1;
          }
        }
        k = 0;
        l = 0;
        prior = 0;
        while(1)
        {
          if (k>=(s_index+c_nindex))
          {
            break;
          }
          if (prior == 0 && l<s_index)
          {
            prior = 1;
            PP_Matrix[k][j].i = s_array[l];
            PP_Matrix[k][j].j = -1;
          }
          else if (prior == 0 && l<c_nindex)
          {
            prior = 0;
            PP_Matrix[k][j].i = -1;
            PP_Matrix[k][j].j = c_narray[l];
            l++;
          }
          else if (prior == 1 && l<c_nindex)
          {
            prior = 0;
            PP_Matrix[k][j].i = -1;
            PP_Matrix[k][j].j = c_narray[l];
            l++;
          }
          else if (prior == 1 && l<s_index)
          {
            prior = 1;
            PP_Matrix[k][j].i = s_array[l];
            PP_Matrix[k][j].j = -1;
            l++;
          }
          k++;
        }
      }
      j = j-restart;
      print_matrix(N,M);
    }
  }
}


void wallace_multiplier_reduction_schema(int N, int M)
{
  unsigned int weight;
  unsigned int local_weight;
  unsigned int current_weight;
  unsigned int index = 0;
  int i,j,k;
  while (1)
  {
    weight = 0;
    for (j=0; j<N+M; j++)
    {
      local_weight = 0;
      for (i=0; i<N; i++)
      {
        if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
        {
          ++local_weight;
        }
      }
      if (weight<local_weight)
      {
        weight = local_weight;
      }
    }
    if (weight<3)
    {
      break;
    }
    for (k=0; k<N; k=k+3)
    {
      local_weight = 0;
      for (j=0; j<N+M; j++)
      {
        current_weight = 0;
        for (i=k; i<k+3; i++)
        {
          if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
          {
            ++current_weight;
          }
        }
        if (local_weight<current_weight)
        {
          local_weight = current_weight;
        }
      }
      if (local_weight<3)
      {
        break;
      }
      for (j=N+M-1; j>=0; j--)
      {
        current_weight = 0;
        for (i=k; i<k+3; i++)
        {
          if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
          {
            ++current_weight;
          }
        }
        print_matrix(N,M);
        if (current_weight == 1)
        {
          if (PP_Matrix[k][j].i<0 && PP_Matrix[k][j].j<0 && PP_Matrix[k+1][j].i<0 && PP_Matrix[k+1][j].j<0)
          {
            if ((PP_Matrix[k][j-1].i>=0 || PP_Matrix[k][j-1].j>=0) || (PP_Matrix[k+1][j-1].i>=0 || PP_Matrix[k+1][j-1].j>=0))
            {
              PP_Matrix[k][j].i = PP_Matrix[k+2][j].i;
              PP_Matrix[k][j].j = PP_Matrix[k+2][j].j;
              PP_Matrix[k+1][j].i = -1;
              PP_Matrix[k+1][j].j = -1;
              PP_Matrix[k+2][j].i = -1;
              PP_Matrix[k+2][j].j = -1;
            }
            else
            {
              PP_Matrix[k+1][j].i = PP_Matrix[k+2][j].i;
              PP_Matrix[k+1][j].j = PP_Matrix[k+2][j].j;
              PP_Matrix[k+2][j].i = -1;
              PP_Matrix[k+2][j].j = -1;
            }
          }
        }
        else if (current_weight == 2)
        {
          string a = PP_Matrix[k][j].print();
          string b = PP_Matrix[k+1][j].print();
          if (PP_Matrix[k][j].i < 0 && PP_Matrix[k][j].j < 0)
          {
            a = PP_Matrix[k+1][j].print();
            b = PP_Matrix[k+2][j].print();
          }
          string cin = "";
          string s = "S("+to_string(index)+")";
          string cout = "C("+to_string(index)+")";
          PP_Matrix[k][j].i = index;
          PP_Matrix[k][j].j = -1;
          PP_Matrix[k+1][j].i = -1;
          PP_Matrix[k+1][j].j = -1;
          PP_Matrix[k+2][j].i = -1;
          PP_Matrix[k+2][j].j = -1;
          PP_Matrix[k+1][j+1].i = -1;
          PP_Matrix[k+1][j+1].j = index;
          Adders.push_back(ADD(a,b,cin,s,cout,0));
          ++index;
        }
        else if (current_weight == 3)
        {
          string a = PP_Matrix[k][j].print();
          string b = PP_Matrix[k+1][j].print();
          string cin = PP_Matrix[k+2][j].print();
          string s = "S("+to_string(index)+")";
          string cout = "C("+to_string(index)+")";
          PP_Matrix[k][j].i = index;
          PP_Matrix[k][j].j = -1;
          PP_Matrix[k+1][j].i = -1;
          PP_Matrix[k+1][j].j = -1;
          PP_Matrix[k+2][j].i = -1;
          PP_Matrix[k+2][j].j = -1;
          PP_Matrix[k+1][j+1].i = -1;
          PP_Matrix[k+1][j+1].j = index;
          Adders.push_back(ADD(a,b,cin,s,cout,1));
          ++index;
        }
      }
    }
    print_matrix(N,M);
    for (k=0; k<(weight/3); k++)
    {
      for (i=0; i<N-1; i++)
      {
        int cond = 0;
        for (j=0; j<N+M; j++)
        {
          if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
          {
            cond = 1;
            break;
          }
        }
        if (cond == 0)
        {
          for (j=0; j<N+M; j++)
          {
            PP_Matrix[i][j].i = PP_Matrix[i+1][j].i;
            PP_Matrix[i][j].j = PP_Matrix[i+1][j].j;
            PP_Matrix[i+1][j].i = -1;
            PP_Matrix[i+1][j].j = -1;
          }
        }
      }
    }
    print_matrix(N,M);
  }
}



void vhdl_code_generation_schema(int type,int N, int M)
{
  int i,j;
  int id = 0;
  int AMOUNT = Adders.size();
  stringstream filename;
  string s_type = "";
  if (type==0)
  {
    s_type = "wallace";
  }
  else if (type==1)
  {
    s_type = "dadda";
  }
  filename << s_type << ".vhd";
  ofstream outfile(filename.str().c_str());
  outfile << "library ieee;" << endl;
  outfile << "use ieee.std_logic_1164.all;" << endl;
  outfile << "use ieee.numeric_std.all;" << endl;
  outfile << "use work.libs.all;" << endl;
  outfile << endl;
  outfile << "entity " << s_type << " is" << endl;
  outfile << "port" << endl;
  outfile << "  (" << endl;
  outfile << "    x             : in  std_logic_vector(" << to_string(N-1) << " downto 0);" << endl;
  outfile << "    y             : in  std_logic_vector(" << to_string(M-1) << " downto 0);" << endl;
  outfile << "    z0            : out std_logic_vector(" << to_string(N+M-1) << " downto 0);" << endl;
  outfile << "    z1            : out std_logic_vector(" << to_string(N+M-1) << " downto 0)" << endl;
  outfile << "  );" << endl;
  outfile << "end " << s_type << ";" << endl;
  outfile << endl;
  outfile << "architecture behavior of " << s_type <<" is" << endl;
  outfile << endl;
  outfile << "type mul_type is array (0 to " << to_string(N-1) <<") of std_logic_vector(" << to_string(M-1) <<" downto 0);" << endl;
  outfile << endl;
  outfile << "signal P : mul_type;" << endl;
  outfile << endl;
  outfile << "signal S : std_logic_vector("+to_string(AMOUNT-1)+" downto 0);" << endl;
  outfile << "signal C : std_logic_vector("+to_string(AMOUNT-1)+" downto 0);" << endl;
  outfile << endl;
  outfile << "begin" << endl;
  outfile << endl;
  for (i=0; i<N; i++)
  {
    for (j=0; j<M; j++)
    {
      outfile << "  P("<<i<<")("<<j<<") <= x("<<i<<") and y("<<j<<");" << endl;
    }
  }
  outfile << endl;
  for (auto v : Adders)
  {
    outfile << v.Print(id) << endl;
    ++id;
  }
  outfile << endl;
  for (i=0; i<2; i++)
  {
    for (j=0; j<N+M; j++)
    {
      if (PP_Matrix[i][j].i < 0 && PP_Matrix[i][j].j < 0 )
        outfile << "  z" << to_string(i) << "(" << to_string(j) + ") <= '0';" << endl;
      else
        outfile << "  z" << to_string(i) << "(" << to_string(j) + ") <= " << PP_Matrix[i][j].print() << ";" << endl;
    }
  }
  outfile << endl;
  outfile << "end architecture;" << endl;
  outfile.close();
}



void verilog_code_generation_schema(int type,int N, int M)
{
  int i,j;
  int id = 0;
  int AMOUNT = Adders.size();
  int str_i,str_j,str_it;
  string str_add;
  stringstream filename;
  string s_type = "";
  if (type==0)
  {
    s_type = "wallace";
  }
  else if (type==1)
  {
    s_type = "dadda";
  }
  filename << s_type << ".sv";
  ofstream outfile(filename.str().c_str());
  outfile << "module " << s_type << endl;
  outfile << "(" << endl;
  outfile << "  input  logic [" << to_string(N-1) << " : 0] x," << endl;
  outfile << "  input  logic [" << to_string(M-1) << " : 0] y," << endl;
  outfile << "  output logic [" << to_string(N+M-1) << " : 0] z0," << endl;
  outfile << "  output logic [" << to_string(N+M-1) << " : 0] z1"<< endl;
  outfile << ");" << endl;
  outfile << "  timeunit 1ps;" << endl;
  outfile << "  timeprecision 1ps;" << endl;
  outfile << endl;
  outfile << "  logic [" << to_string(M-1) << " : 0] P [0 : " << to_string(N-1) << "];" << endl;
  outfile << endl;
  outfile << "  logic [" << to_string(AMOUNT-1) << " : 0] S;" << endl;
  outfile << "  logic [" << to_string(AMOUNT-1) << " : 0] C;" << endl;
  outfile << endl;
  for (i=0; i<N; i++)
  {
    for (j=0; j<M; j++)
    {
      outfile << "  assign P["<<i<<"]["<<j<<"] = x["<<i<<"] & y["<<j<<"];" << endl;
    }
  }
  outfile << endl;
  for (auto v : Adders)
  {
    str_add = v.Print(id,"verilog");
    str_i = str_add.find_first_of("(");
    str_j = str_add.find_last_of(")");
    for (str_it = str_i+1; str_it<str_j; str_it++)
    {
      if (str_add[str_it] == '(')
        str_add[str_it] = '[';
      else if (str_add[str_it] == ')')
        str_add[str_it] = ']';
    }
    outfile << str_add << endl;
    ++id;
  }
  outfile << endl;
  for (i=0; i<2; i++)
  {
    for (j=0; j<N+M; j++)
    {
      if (PP_Matrix[i][j].i < 0 && PP_Matrix[i][j].j < 0 )
        outfile << "  assign z" << to_string(i) << "[" << to_string(j) + "] = 0;" << endl;
      else
        outfile << "  assign z" << to_string(i) << "[" << to_string(j) + "] = " << PP_Matrix[i][j].print("verilog") << ";" << endl;
    }
  }
  outfile << endl;
  outfile << "endmodule" << endl;
  outfile.close();
}


int main(int argc, char *argv[])
{
  int type = -1;
  int N = -1;
  int M = -1;
  int i = 0;
  if (argc < 4)
  {
      cout << "Usage: " << argv[0] << " <type>" << " <N>" << " <M> " << endl;
      cout << "Valid types: <dadda> or <wallace>" << endl;
      cout << "Valid N,M: e.g. <32,64> for 32x64 binary multiplication" << endl;
      return 0;
  }
  if (!strcmp(argv[1],"wallace"))
  {
    cout << "Wallace-Tree choosen!" << endl;
    type = 0;
  }
  else if (!strcmp(argv[1],"dadda"))
  {
    cout << "Dadda-Tree choosen!" << endl;
    type = 1;
  }
  else
  {
    cout << "Invalid type choosen!" << endl;
    return 0;
  }
  i=0;
  for (; argv[2][i] != 0; i++)
  {
      if (!isdigit(argv[2][i]))
      {
        cout << "Invalid N given!" << endl;
        return 0;
      }
  }
  i=0;
  for (; argv[3][i] != 0; i++)
  {
      if (!isdigit(argv[3][i]))
      {
        cout << "Invalid M given!" << endl;
        return 0;
      }
  }
  stringstream dimN(argv[2]);
  dimN >> N;
  stringstream dimM(argv[3]);
  dimM >> M;

  cout << "Multipy-Tree N: " << N << " M: " << M << endl;

  partial_product_generation_schema(type,N,M);
  print_matrix(N,M);
  if (type == 0)
  {
    wallace_multiplier_reduction_schema(N,M);
  }
  else if (type == 1)
  {
    dadda_multiplier_reduction_schema(N,M);
  }
  vhdl_code_generation_schema(type,N,M);
  verilog_code_generation_schema(type,N,M);
}
