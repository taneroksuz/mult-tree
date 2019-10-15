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
  string print();
};

PP::PP(int i,int j)
{
  this->i = i;
  this->j = j;
}

string PP::print()
{
  string out = "";
  if (this->i>=0 && this->j>=0)
    out = "P("+to_string(this->i)+")("+to_string(this->j)+")";
  if (this->i>=0 && this->j<0)
    out = "S("+to_string(this->i)+")";
  if (this->i<0 && this->j>=0)
    out = "C("+to_string(this->j)+")";
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
  string Print(int id);
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

string ADD::Print(int id)
{
  stringstream adder;
  if (this->type==0)
  {
    adder << "  HA_"<< format_account_number(id) <<" : ha port map ("<<this->a<<","<<this->b<<","<<this->s<<","<<this->cout<<");";
  }
  else if (this->type==1)
  {
    adder << "  FA_"<< format_account_number(id) <<" : fa port map ("<<this->a<<","<<this->b<<","<<this->cin<<","<<this->s<<","<<this->cout<<");";
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

void print_matrix(int N)
{
#ifdef DEBUG
  int i,j;
  int value;
  for (i=0; i<2*N; i++)
  {
    cout << endl;
    for (j=0; j<2*N; j++)
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

void partial_product_generation_schema(int type, int N)
{
  int i,j,k;
  int new_i;
  PP_Matrix = (PP**) malloc((2*N)*sizeof(PP*));
  for (i=0; i<2*N; i++)
  {
    PP_Matrix[i] = (PP*) malloc((2*N)*sizeof(PP));
    for (j=0; j<2*N; j++)
    {
      PP_Matrix[i][j].i = -1;
      PP_Matrix[i][j].j = -1;
    }
  }
  if (type==0)
  {
    for (i=0; i<N; i++)
    {
      for (j=0; j<N; j++)
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
      for (j=0; j<N; j++)
      {
        if (i+j<N)
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

void dadda_multiplier_reduction_schema(int N)
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
    for (j=0; j<2*N; j++)
    {
      local_weight = 0;
      for (i=0; i<2*N; i++)
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
    for (j=0; j<2*N; j++)
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
      for (i=0; i<2*N; i++)
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
      print_matrix(N);
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
      print_matrix(N);
      for (k=0; k<num; k++)
      {
        for (i=0; i<2*N-1; i++)
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
      print_matrix(N);
      if (restart == 0)
      {
        for (k=0; k<(c_nindex+s_index); k++)
        {
          for (i=2*N-1; i>0; i--)
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
      print_matrix(N);
    }
  }
}


void wallace_multiplier_reduction_schema(int N)
{
  unsigned int weight;
  unsigned int local_weight;
  unsigned int current_weight;
  unsigned int index = 0;
  int i,j,k;
  while (1)
  {
    weight = 0;
    for (j=0; j<2*N; j++)
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
      for (j=0; j<2*N; j++)
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
      for (j=2*N-1; j>=0; j--)
      {
        current_weight = 0;
        for (i=k; i<k+3; i++)
        {
          if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
          {
            ++current_weight;
          }
        }
        print_matrix(N);
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
    print_matrix(N);
    for (k=0; k<(weight/3); k++)
    {
      for (i=0; i<N-1; i++)
      {
        int cond = 0;
        for (j=0; j<2*N; j++)
        {
          if (PP_Matrix[i][j].i>=0 || PP_Matrix[i][j].j>=0)
          {
            cond = 1;
            break;
          }
        }
        if (cond == 0)
        {
          for (j=0; j<2*N; j++)
          {
            PP_Matrix[i][j].i = PP_Matrix[i+1][j].i;
            PP_Matrix[i][j].j = PP_Matrix[i+1][j].j;
            PP_Matrix[i+1][j].i = -1;
            PP_Matrix[i+1][j].j = -1;
          }
        }
      }
    }
    print_matrix(N);
  }
}



void vhdl_code_generation_schema(int type,int N)
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
  outfile << "    y             : in  std_logic_vector(" << to_string(N-1) << " downto 0);" << endl;
  outfile << "    z0            : out std_logic_vector(" << to_string(2*N-1) << " downto 0);" << endl;
  outfile << "    z1            : out std_logic_vector(" << to_string(2*N-1) << " downto 0)" << endl;
  outfile << "  );" << endl;
  outfile << "end " << s_type << ";" << endl;
  outfile << endl;
  outfile << "architecture behavior of " << s_type <<" is" << endl;
  outfile << endl;
  outfile << "type mul_type is array (0 to " << to_string(N-1) <<") of std_logic_vector(" << to_string(N-1) <<" downto 0);" << endl;
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
    for (j=0; j<N; j++)
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
    for (j=0; j<2*N; j++)
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


int main(int argc, char *argv[])
{
  int type = -1;
  int size = -1;
  int i = 0;
  if (argc < 3)
  {
      cout << "Usage: " << argv[0] << " <type>" << " <size>" << endl;
      cout << "Valid types: <dadda> or <wallace>" << endl;
      cout << "Valid size: e.g. <32> for 32x32 binary multiplication" << endl;
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
  for (; argv[2][i] != 0; i++)
  {
      if (!isdigit(argv[2][i]))
      {
        cout << "Invalid size given!" << endl;
        return 0;
      }
  }
  stringstream ssize(argv[2]);
  ssize >> size;

  cout << "Multipy-Tree size: " << size << "x" << size << endl;

  partial_product_generation_schema(type,size);
  print_matrix(size);
  if (type == 0)
  {
    wallace_multiplier_reduction_schema(size);
  }
  else if (type == 1)
  {
    dadda_multiplier_reduction_schema(size);
  }
  vhdl_code_generation_schema(type,size);
}
