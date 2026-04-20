using Npgsql;
using System;
using System.Data;
using System.Drawing;
using System.Globalization;
// using System.Reflection.Emit;
using System.Windows.Forms;
using static System.Windows.Forms.DataFormats;

namespace PgDataGridWinForms
{
    public class MainForm : Form
    {
        int krueckesummeberechnenaktiv = 0;
        private NpgsqlConnection conn2;
        private NpgsqlDataAdapter adapter2;
        private NpgsqlCommandBuilder builder2;
        
        private Panel PanelPreview1      = new Panel();
        private Panel PanelGrid1         = new Panel();
        private Panel PanelGrid1A        = new Panel();
        private Panel PanelGrid2         = new Panel();  // Datensätze mit gleicher Art

        private Panel PanelDebug1        = new Panel();
        private Panel PanelButtons1      = new Panel();

        private DataGridView grid        = new DataGridView();
        private DataGridView gridSameAmount = new DataGridView();
        private DataView viewSameAmount;
        private Label labelSameAmount    = new Label();
        private Button loadButton        = new Button();
        private Button saveButton        = new Button();
        private Button gtmButton1        = new Button();
        private Button gtmButton2        = new Button();
        private Button PreviewSaveButton = new Button();


        private TextBox textBox00 = new TextBox();
        private TextBox textBox01 = new TextBox();
        private TextBox textBox02 = new TextBox();
        private TextBox textBox03 = new TextBox();
        private TextBox textBox04 = new TextBox();
        private TextBox textBox05 = new TextBox();
        private TextBox textBox06 = new TextBox();
        private TextBox textBox07 = new TextBox();
        private TextBox textBox08 = new TextBox();
        private TextBox textBox09 = new TextBox();
        private TextBox textBox10 = new TextBox();

        private Label grid1Asumme = new Label();


        private TextBox textBoxCursorCol = new TextBox();
        private TextBox textBoxCursorRow = new TextBox();
        private TextBox textBoxEvent     = new TextBox();

        private DataTable table = new DataTable();
   //     private DataGridViewCellStyle style;
        // TODO: connection string anpassen
        private string connString = "Host=192.168.207.160;Port=5432;Username=postgres;Password=Ole1brumm;Database=RK2";

        public MainForm(int paravonhauptprg)  // hier könnte man von Hauptprogramm command line parameter holen, muss nur umstellen auf 2 Strings oder ein Array
        {

            
            conn2 = new NpgsqlConnection(connString);
            
            // adapter2 = new NpgsqlDataAdapter("SELECT * FROM public.test2view", conn2);
            adapter2 = new NpgsqlDataAdapter("SELECT * FROM public.buchpos", conn2);
            
            builder2 = new NpgsqlCommandBuilder(adapter2);

            Text = "GTM: Turbo DataGrid ";
            Width  = 1400;
            Height = 900;

            // Ebene 1 -------------------------------------------------------
            this.Controls.Add( PanelPreview1);
            this.Controls.Add(PanelGrid1);
            this.Controls.Add(PanelGrid1A); // ergänzende Felder zu GRID
            this.Controls.Add(PanelGrid2);  // Grid: Datensätze mit gleicher Art

            this.Controls.Add( PanelDebug1);
            this.Controls.Add( PanelButtons1) ;

            // 1 - Preview
            PanelPreview1.Location = new Point(800, 0);
            PanelPreview1.Size = new Size(500, 600);
            PanelPreview1.BorderStyle = BorderStyle.FixedSingle;
            // 1 - Grid
            PanelGrid1.Location = new Point(0, 0);
            PanelGrid1.Size = new Size(800, 500);
            PanelGrid1.BorderStyle = BorderStyle.FixedSingle;

            PanelGrid1A.Location = new Point(520, 500);
            PanelGrid1A.Size = new Size(300, 200);
            PanelGrid1A.BorderStyle = BorderStyle.FixedSingle;

            // 1 - Grid2: Datensätze mit gleicher Art (unter Haupt-Grid)
            PanelGrid2.Location = new Point(0, 500);
            PanelGrid2.Size = new Size(800, 200);
            PanelGrid2.BorderStyle = BorderStyle.FixedSingle;

            // 1 - Buttons
            PanelButtons1.Location = new Point(10, 710);
            PanelButtons1.Size = new Size(500, 40);
            PanelButtons1.BorderStyle = BorderStyle.FixedSingle;

            // 1 - Debug
            PanelDebug1.Location = new Point(0, 710);
            PanelDebug1.Size = new Size(100, 110);
            PanelDebug1.BorderStyle = BorderStyle.FixedSingle;

            // Ebene 2 ------------------------------------------------------

            // 2 - Grid Panel
            grid.Dock = DockStyle.Top;
            grid.Width = 800;
            grid.Height = 500;

            PanelGrid1.Controls.Add(grid);

            // 2 - Grid Ergänzung Panel
            grid1Asumme.Text  = "";
            grid1Asumme.Top   = 10;
            grid1Asumme.Left  = 10;
            grid1Asumme.Width = 180;
            grid1Asumme.Font = new Font("Times New Roman", 12, FontStyle.Bold);

            PanelGrid1A.Controls.Add(grid1Asumme);

            // 2 - Grid2 Panel (gleiche Art)
            labelSameAmount.Text = "Datensätze mit gleicher Art:";
            labelSameAmount.Top = 2;
            labelSameAmount.Left = 5;
            labelSameAmount.AutoSize = true;
            labelSameAmount.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            PanelGrid2.Controls.Add(labelSameAmount);

            gridSameAmount.Top = 22;
            gridSameAmount.Left = 0;
            gridSameAmount.Width = 798;
            gridSameAmount.Height = 174;
            gridSameAmount.ReadOnly = true;
            gridSameAmount.RowHeadersVisible = false;
            gridSameAmount.AllowUserToAddRows = false;
            gridSameAmount.AllowUserToDeleteRows = false;
            PanelGrid2.Controls.Add(gridSameAmount);

            // 2 - Buttons Panel

            loadButton.Text = "Laden";
            loadButton.Top = 0;
            loadButton.Left = 0;
            loadButton.Click += LoadData;

            saveButton.Text = "Speichern";
            saveButton.Top = 0;
            saveButton.Left = 90;
            saveButton.Click += SaveData;

            gtmButton1.Text = "Bt1. gtm";
            gtmButton1.Top = 0;
            gtmButton1.Left = 180;
            gtmButton1.Click += ButtonGTM1;
            
            gtmButton2.Text = "update row";
            gtmButton2.Top = 0;
            gtmButton2.Left = 270;
            gtmButton2.Click += ButtonGTM2;

            PanelButtons1.Controls.Add( loadButton );
            PanelButtons1.Controls.Add( saveButton );
            PanelButtons1.Controls.Add( gtmButton1 );
            PanelButtons1.Controls.Add( gtmButton2 );


            // 2 - Debug Panel
            textBoxCursorRow.Text = paravonhauptprg.ToString();    // "-";
            textBoxCursorRow.Width = 40;
            textBoxCursorRow.Left = 10;
            textBoxCursorRow.Top = 10;

            textBoxCursorCol.Text  = "-";
            textBoxCursorCol.Width = 40;
            textBoxCursorCol.Left  = 10;
            textBoxCursorCol.Top   = 40;

            textBoxEvent.Text  = "-";
            textBoxEvent.Width = 200;
            textBoxEvent.Left  = 10;
            textBoxEvent.Top   = 70;

            PanelDebug1.Controls.Add( textBoxCursorCol );
            PanelDebug1.Controls.Add( textBoxCursorRow );
            PanelDebug1.Controls.Add( textBoxEvent );
            
            // 2 - Preview

            int startx = 10;int starty = 10;
            int hoehe = 30;
            
            textBox00.Text = "t00";
            textBox00.Width = 120;
            textBox00.Top = starty + 0 * hoehe;
            textBox00.Left = startx;

            textBox01.Text = "t01";
            textBox01.Width = 120;
            textBox01.Top = starty + 1* hoehe;
            textBox01.Left = startx;

            textBox02.Text = "t02";
            textBox02.Width = 120;
            textBox02.Top = starty + 2*hoehe;
            textBox02.Left = startx;

            textBox03.Text = "t03";
            textBox03.Width = 120;
            textBox03.Top = starty+ 3* hoehe;
            textBox03.Left = startx;

            textBox04.Text = "t04";
            textBox04.Width = 120;
            textBox04.Top = starty+ 4* hoehe;
            textBox04.Left = startx;

            textBox05.Text = "t05";
            textBox05.Width = 120;
            textBox05.Top = starty + 5 * hoehe;
            textBox05.Left = startx;

            textBox06.Text = "text 06       ";
            textBox06.Width = 120;
            textBox06.Top = starty + 6 * hoehe;
            textBox06.Left = startx;

            textBox07.Text = "t07";
            textBox07.Width = 120;
            textBox07.Top = starty + 7 * hoehe;
            textBox07.Left = startx;

            textBox08.Text = "t08";
            textBox08.Width = 120;
            textBox08.Top = starty + 8 * hoehe;
            textBox08.Left = startx;

            textBox09.Text = "t09";
            textBox09.Width = 120;
            textBox09.Top = starty + 9 * hoehe;
            textBox09.Left = startx;

            textBox10.Text = "t10";
            textBox10.Width = 120;
            textBox10.Top = starty + 10 * hoehe;
            textBox10.Left = startx;

            PreviewSaveButton.Text = "save row";
            PreviewSaveButton.Top = starty + 15 * hoehe;
            PreviewSaveButton.Left = startx;
            PreviewSaveButton.Click += ButtonSavePreview;


            PanelPreview1.Controls.Add( textBox00);
            PanelPreview1.Controls.Add( textBox01);
            PanelPreview1.Controls.Add( textBox02);
            PanelPreview1.Controls.Add( textBox03);
            PanelPreview1.Controls.Add( textBox04);
            PanelPreview1.Controls.Add( textBox05);
            PanelPreview1.Controls.Add( textBox06);
            PanelPreview1.Controls.Add( textBox07);
            PanelPreview1.Controls.Add( textBox08);
            PanelPreview1.Controls.Add( textBox09);
            PanelPreview1.Controls.Add( textBox10);
            PanelPreview1.Controls.Add( PreviewSaveButton );

            // Ende Ebene 2


            // Daten direkt laden
            LoadData(this, EventArgs.Empty); // direktes Laden der SQL Tabelle
            

        }

        private void LoadData(object sender, EventArgs e)
        {
            // wenn man Tabellen in GrossKlein schreiben will, ist es möglich, aber umständlich z.B. "SELECT * FROM public.\"Buchungen\" order by gewerk"
            using var conn = new NpgsqlConnection(connString);
            //  alle Datensätze: var adapter = new NpgsqlDataAdapter("SELECT * FROM public.buchpos" order by gewerk", conn);
           //   alle mit AN     : var adapter = new NpgsqlDataAdapter("SELECT * FROM public.buchpos where art='AN' order by gewerk", conn);
           //   auf eine View!!!
           var adapter = new NpgsqlDataAdapter("SELECT * FROM public.test2view", conn);
            var builder = new NpgsqlCommandBuilder(adapter);

            table.Clear();
            adapter.Fill(table);
            grid.DataSource = table;

            // gtm
            //grid.Columns[0].Name = "internal name"; // interner Name
                     
            grid.EnableHeadersVisualStyles = false; // Grundvoraussetzung um Layout zu verändern

            grid.Columns[0].ReadOnly = true; // Spalte 0 zu Testzwecken readonly

            grid.GridColor = Color.Black;
            grid.BackgroundColor = Color.Azure;
            grid.RowHeadersVisible = false;

            grid.Columns[0].HeaderText = "Sp.0: ID";
           
            grid.Columns[1].HeaderText = " -Betrag-";
            grid.Columns[1].HeaderCell.Style.Alignment = DataGridViewContentAlignment.MiddleRight; // Überschrift rechtsbündig
            // Spalte 2 = Betrag ist numerisch, 2 Nachkomma
            grid.Columns[1].DefaultCellStyle.Format    = "C2"; // N2 ist numerisch, c2 ist währung
            grid.Columns[1].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            grid.Columns[1].DefaultCellStyle.FormatProvider = System.Globalization.CultureInfo.GetCultureInfo("de-DE"); // deutscxhes Format EURO
            // alles rechtsbündig
            grid.Columns[1].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            grid.Columns[2].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            grid.Columns[3].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            grid.Columns[4].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            grid.Columns[5].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
            grid.Columns[6].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
          
            // Event Handler zuordnen
            grid.CellClick += dataGridView1_CellClick;
            grid.CellClick += dataGridView1_CellEnter;
            grid.CurrentCellChanged += dataGridView1_CurrentCellChanged;       // Cursor wurde in andere Zelle bewegt
            grid.CellValueChanged += dataGridView1_CellValueChanged;           // Wert hat sich verändert
            
            
            // testweise, aufgrund microsoft hilfe
             grid.ColumnHeaderCellChanged += dataGridView1_ColumnHeaderCellChanged;           // mittlerweile obsolet


            var style = grid.ColumnHeadersDefaultCellStyle;
            style.BackColor = Color.Navy;
            style.ForeColor = Color.White;
            style.Font = new Font(grid.Font, FontStyle.Bold);

            // DataView für zweites Grid (gleiche Art)
            viewSameAmount = new DataView(table);
            viewSameAmount.RowFilter = "1=0"; // initial leer
            gridSameAmount.DataSource = viewSameAmount;
            gridSameAmount.EnableHeadersVisualStyles = false;
            gridSameAmount.GridColor = Color.Black;
            gridSameAmount.BackgroundColor = Color.LightYellow;
            if (gridSameAmount.Columns.Count > 0)
            {
                gridSameAmount.Columns[0].HeaderText = "Sp.0: ID";
                if (gridSameAmount.Columns.Count > 1)
                {
                    gridSameAmount.Columns[1].HeaderText = " -Betrag-";
                    gridSameAmount.Columns[1].DefaultCellStyle.Format = "C2";
                    gridSameAmount.Columns[1].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleRight;
                    gridSameAmount.Columns[1].DefaultCellStyle.FormatProvider = CultureInfo.GetCultureInfo("de-DE");
                }
                var style2 = gridSameAmount.ColumnHeadersDefaultCellStyle;
                style2.BackColor = Color.DarkGreen;
                style2.ForeColor = Color.White;
                style2.Font = new Font(gridSameAmount.Font, FontStyle.Bold);
            }
            UpdateSameAmountGrid();
        }

        private void UpdateSameAmountGrid()
        {
            if (viewSameAmount == null || grid.CurrentCell == null)
                return;
            int rowIndex = grid.CurrentCell.RowIndex;
            if (rowIndex < 0 || rowIndex >= grid.Rows.Count)
                return;
            string artCol = table.Columns.Contains("Art") ? "Art" : (table.Columns.Contains("art") ? "art" : "Art");
            var cellArt = grid.Rows[rowIndex].Cells[artCol];
            if (cellArt?.Value == null || cellArt.Value == DBNull.Value || string.IsNullOrEmpty(cellArt.Value.ToString()))
            {
                viewSameAmount.RowFilter = "1=0";
                return;
            }
            string art = cellArt.Value.ToString().Replace("'", "''"); // Einfache Anführungszeichen für RowFilter escapen
            viewSameAmount.RowFilter = $"{artCol} = '{art}'";
        }


        // neuer Button Spielwiese für UPDATE 
        private void ButtonGTM2(object sender, EventArgs e)
        {
            // speichern
            // führt zu Fehlermeldung wenn es view ist
            // adapter2.Update(table);
            var drv = grid.CurrentRow?.DataBoundItem as DataRowView;
            if (drv == null) return;

            DataRow row = drv.Row;

            if (row.RowState == DataRowState.Modified)
            {
                adapter2.Update(new DataRow[] { row });
                MessageBox.Show("Zeile gespeichert");
            }


            BerechneSumme();

        }
        
        private void ButtonGTM1(object sender, EventArgs e)
        {
            // speichern
            // führt zu Fehlermeldung wenn es view ist
            adapter2.Update(table);

            // komplett neu laden, unsicher ob richtige Methode
            table.Clear();
            builder2 = new NpgsqlCommandBuilder(adapter2);
            adapter2.Fill(table);
            grid.DataSource = table;

        }

        private void BerechneSumme() // es muss SPalte mit dem Namen "Betrag" geben
        {
            decimal summe = 0;

            if (krueckesummeberechnenaktiv == 1) // falls dies ein rekursiver Aufruf ist, sofort beenden
                return;
            krueckesummeberechnenaktiv = 1;  // am Anfang der Funktion markieren, dass berechnen summe aktiv

            if (grid == null)
                return;

            foreach (DataGridViewRow row in grid.Rows)
            {
                if (row.Cells["Betrag"].Value != null)
                    summe += Convert.ToDecimal(row.Cells["Betrag"].Value);
            }

             grid1Asumme.Text = $"Summe: {summe:N2}";
            grid.Columns[1].HeaderText = $"{summe:N2}";  // dies ist das Problem: hier würde vermutlich wieder cellvalue changed getriggert, damit rekursiver Aufruf, unendlich

            
            krueckesummeberechnenaktiv = 0;  // am Ende Flag wieder zurücksetzen

        }


        private void ButtonSavePreview(object sender, EventArgs e)
        {
            var cmd = new NpgsqlCommand(
            "UPDATE buchpos SET bvh=@bvh,test=@test,betrag=@betrag,art=@art,gewerk=@gewerk WHERE pk1=@pk1", conn2);

          
            cmd.Parameters.AddWithValue("@gewerk",  textBox02.Text);
            cmd.Parameters.AddWithValue("@bvh",     textBox03.Text);
            cmd.Parameters.AddWithValue("@art",     textBox04.Text);
            cmd.Parameters.AddWithValue("@test",    textBox05.Text);
            // tricky1: Betrag
            decimal betrag = decimal.Parse(textBox01.Text , CultureInfo.CurrentCulture);
            
            cmd.Parameters.AddWithValue("@betrag", betrag); // 

            // tricky2: Primärschlüssel
            Int32 ganzzahl;
            ganzzahl = 0;
            if (!string.IsNullOrWhiteSpace(textBox00.Text))
            {
                if (int.TryParse(textBox00.Text, out int tmp))
                {
                    ganzzahl = tmp;
                }
            }
            cmd.Parameters.Add("@pk1", NpgsqlTypes.NpgsqlDbType.Integer).Value = (object?)ganzzahl ?? DBNull.Value;


            conn2.Open();
            cmd.ExecuteNonQuery();
            conn2.Close();

        }
        private void InitializeComponent()
        {
            SuspendLayout();
            // 
            // MainForm
            // 
            ClientSize = new Size(576, 448);
            Name = "MainForm";
            ResumeLayout(false);

        }

        private void SaveData(object sender, EventArgs e)
        {
            using var conn = new NpgsqlConnection(connString);
            var adapter = new NpgsqlDataAdapter("SELECT * FROM public.buchpos", conn);
            var builder = new NpgsqlCommandBuilder(adapter);

            adapter.Update(table);
            MessageBox.Show("Änderungen gespeichert");
        }


        // gridview Event Handler

        private void dataGridView1_ColumnHeaderCellChanged(Object sender, DataGridViewColumnEventArgs e)
         {
        
            System.Text.StringBuilder messageBoxCS = new System.Text.StringBuilder();
            MessageBox.Show(messageBoxCS.ToString(), "ColumnHeaderCellChanged Event");
         }




        private void dataGridView1_CellClick(object sender,
            DataGridViewCellEventArgs e)
        {
            string zellentext = grid.CurrentCell.Value?.ToString();
            textBox01.Text = zellentext;

            textBoxCursorRow.Text = e.RowIndex.ToString();
            textBoxCursorCol.Text = e.ColumnIndex.ToString();
            textBoxEvent.Text = "CellClick";
        }
        private void dataGridView1_CellEnter(object sender,
            DataGridViewCellEventArgs e)
        {
            textBoxEvent.Text = "Cell Enter";
            update_preview();
        }
        private void dataGridView1_CurrentCellChanged(object sender,
           EventArgs e)  //  
        {
            // TODO: man muss abfangen, wenn auf Spaltenüberschrift geklickt wird!! --> sonst exception und man fliegt raus!!

            if (grid.CurrentCell == null)
                return;

            textBoxCursorRow.Text = grid.CurrentCell.RowIndex.ToString();
            textBoxCursorCol.Text = grid.CurrentCell.ColumnIndex.ToString();

            string zellentext = grid.CurrentCell.Value?.ToString();
            textBox01.Text = zellentext;
            textBoxEvent.Text = "neue Zelle";
                       
            update_preview();
            UpdateSameAmountGrid();
        }

        private void dataGridView1_CellValueChanged(object sender,
           DataGridViewCellEventArgs e)  //  EventArgs <<<----das geht
        {
            // NB!  verhindern von Rekursion / Zyklen
            // die Summe steht ja in der Tabelle selber, also darf das Ändern der Summe nicht wieder zu einem Trigger Event führen
           //   laut chatgpt wäre das nicht der Fall, gehört Header nicht zu den Zellen, ist aber trotzddem so
           
            string zellentext = grid.CurrentCell.Value?.ToString();
            if (zellentext == null)
                return;
            if (textBox01 == null)
                return;

            textBox01.Text = zellentext;
            textBoxEvent.Text = "zelle geändert";
            BerechneSumme();  // funktioniert, aber aufpassen wegen Rekursion, unendlich
            UpdateSameAmountGrid();
        }
        
        // aktualisere Textboxen
        private void update_preview() {
            textBox01.Text = "update-felder";

            int row1;
            row1 = grid.CurrentCell.RowIndex;

            textBox00.Text = grid.Rows[row1].Cells[0].Value.ToString();
            textBox01.Text = grid.Rows[row1].Cells[1].Value.ToString();
            textBox02.Text = grid.Rows[row1].Cells[2].Value.ToString();
            textBox03.Text = grid.Rows[row1].Cells[3].Value.ToString();
            textBox04.Text = grid.Rows[row1].Cells[4].Value.ToString();
            textBox05.Text = grid.Rows[row1].Cells[5].Value.ToString();

        }

    }
}
